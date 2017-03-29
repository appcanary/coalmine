require 'test_helper'

class CreateFoos < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :foos do |t|
      t.string :name
      t.references :bars
      t.timestamps null: false
    end
  end
end

class AlterFoos < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :foos do |t|
      t.string :new_field, default: "default"
    end
  end
end

class FooArchive < ActiveRecord::Base
  # I am a model's archive!
end

class Foo < ActiveRecord::Base
  # I am a model!
  has_many :archives, :class_name => FooArchive
end

class ArchiveMigratorTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  def setup
    CreateFoos.new.exec_migration(ActiveRecord::Base.connection, :up)
  end
  def teardown
    # This will not clean up triggers, so those will hang around the test db. I
    # think this shouldn't break things too much, until the ArchiveMigrator
    # learns to reverse the triggers

    CreateFoos.new.exec_migration(ActiveRecord::Base.connection, :down)
  end

  it "should creaate archive tables" do
    f = Foo.create(name: "a name")
    assert_equal 1, Foo.count
    assert_equal 0, FooArchive.count

    f.bars_id = 123
    f.save
    f.reload

    assert_equal 1, Foo.count
    assert_equal 1, FooArchive.count

    assert_equal 123, f.bars_id
    assert_equal nil, f.archives.first.bars_id
  end

  it "should trigger updates to created_at" do
    f = Foo.create(name: "a name")

    f.reload
    old_valid_at = f.valid_at
    assert f.created_at == f.updated_at

    f.name = "changed my name"
    f.save
    f.reload

    # The updated_at timestamp should come after create, and valid should be the same as updated at because of the update trigger
    assert f.created_at != f.updated_at
    assert old_valid_at != f.valid_at
  end

  it "should let you alter tables" do
    f = Foo.create(name: "a name")
    f.name = "changed my name"
    f.save
    f.reload

    fa = f.archives.first


    assert_raises(NoMethodError) { f.new_field }
    assert_raises(NoMethodError) { fa.new_field }
    AlterFoos.new.exec_migration(ActiveRecord::Base.connection, :up)

    f.reload
    assert_equal "default", f.new_field
    fa.reload
    assert_equal "default", fa.new_field

    AlterFoos.new.exec_migration(ActiveRecord::Base.connection, :down)
  end

end
