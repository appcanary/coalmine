# TODO: document
module ArchiveBehaviour
  def as_of(time_t)
    from(build_as_of(time_t))
  end

  def union_str(arel1, arel2)
    "((#{arel1.to_sql}) UNION ALL (#{arel2.to_sql})) #{self.table_name}"
  end

  def build_as_of(time_t)
    union_str(all.where("valid_at <= ? and expired_at > ?", time_t, time_t),
              self.archive_class.select_as_archived.where("valid_at <= ? and expired_at > ?", time_t, time_t))

  end

  def revisions
    from(union_str(all, archive_class.select_as_archived)).
      select("distinct(#{self.table_name}.valid_at)").
      order(:valid_at)
  end
end
