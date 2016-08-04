# ServiceMakers are ServiceManagers
# that are only ever called from ServiceManagers.
#
# Why is this distinction necessary?
# ServiceMakers issue a lot of calls that have to be wrapped
# within transactions. This is to say, should any aspect
# of their call stack fail, we should reject the set of changes
# as a whole.
#
# In activerecord, nested transactions behave unintuitively.
#
# See: http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html ("nested transactions").
=begin
# For example, the following behavior may be surprising:
# 
# User.transaction do
#   User.create(username: 'Kotori')
#   User.transaction do
#     User.create(username: 'Nemu')
#     raise ActiveRecord::Rollback
#   end
# end
# creates both “Kotori” and “Nemu”. Reason is the ActiveRecord::Rollback exception in the nested block does not issue a ROLLBACK. Since these exceptions are captured in transaction blocks, the parent block does not see it and the real transaction is committed.
=end
# 
# Also see: http://stackoverflow.com/questions/20926873/bubbling-up-nested-transaction-failures-with-activerecord
#
# You're supposed to issue a transaction(requires_new: true) if
# you're actually in a sub transaction. 
#
# But in the "makers" I've written so far, I don't actually
# want subtransactions. If while creating a new bundle, the
# new packages it creates as a side effect fail for whatever
# reason, the bundle itself should not be committed either.
#
# if while creating a new package, a vulnerabilepackage 
# association fails to be made for some reason, then i 
# want the whole thing to fail loudly also, instead of
# this inbetween state.
#
# So, I have transactions that are dependent across different
# ServiceManagers and ServiceMakers. Instead of nesting txns,
# let's just have a ServiceMaker check to see if it's in a txn.
#
# Since at time of writing we expect to have only one database
# connection, this should work just fine.
#
# In conclusion: ServiceManagers control what is in a txn. 
# ServiceMakers assume/enforce that they're in one.

class ServiceMaker < ServiceManager

  # this is a weak check; you can init
  # the object inside a txn then issue
  # your queries outside of it. But for now...
  def self.inherited(klass)
    class << klass
      alias_method :__new, :new
      def new(*args)
        e = __new(*args)
        e.__validate_transaction!
        e
      end
    end
  end

  def __validate_transaction!
    raise "Not in transaction!" if ActiveRecord::Base.connection.open_transactions < 1
  end
end
