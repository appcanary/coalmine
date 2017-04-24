# TODO: document and TEST!
module ArchiveBehaviour
  def self.extended(klass)
    archive_class = (klass.to_s + "Archive").constantize
    klass.const_set(:ARCHIVE_CLASS, archive_class)
  end

  def as_of(time_t)
    from(build_as_of(time_t))
  end

  def union_str(arel1, arel2)
    "((#{arel1.to_sql}) UNION ALL (#{arel2.to_sql})) #{self.table_name}"
  end

  def build_as_of(time_t)
    union_str(all.where("valid_at <= ? and expired_at > ?", time_t, time_t),
              self::ARCHIVE_CLASS.select_as_archived.where("valid_at <= ? and expired_at > ?", time_t, time_t))

  end

  def deleted
    archive_table_name = self::ARCHIVE_CLASS.table_name
    archived_col = (self::ARCHIVE_CLASS)::ARCHIVED_COL

    self::ARCHIVE_CLASS.select_as_archived.
      # look only at the most recently expired rows
      joins("inner join (select #{archived_col}, max(expired_at) expired_at from #{archive_table_name} group by #{archived_col}) max_row on #{archive_table_name}.#{archived_col} = max_row.#{archived_col} and #{archive_table_name}.expired_at = max_row.expired_at").
      # look only at rows that do not currently exist in AgentServer table
      joins("left join #{self.table_name} on #{self.table_name}.id = #{archive_table_name}.#{archived_col}").
      where("#{self.table_name}.id is null").
      order("id, #{archive_table_name}.expired_at DESC")
  end


  def created_on(date)
    from(union_str(all, self.deleted)).
      where('created_at >= ? and created_at <= ?', date.at_beginning_of_day, date.at_end_of_day)
  end

  def deleted_on(date)
    from("(#{self.deleted.to_sql}) #{self.table_name}").
      # and only look at stuff from this day in particular
      where("expired_at >= ? and expired_at <= ?", date.at_beginning_of_day, date.at_end_of_day)
  end

  def revisions
    from(union_str(all, self::ARCHIVE_CLASS.select_as_archived)).
      select("distinct(#{self.table_name}.valid_at)").
      order(:valid_at)
  end
end
