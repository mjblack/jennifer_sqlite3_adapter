require "../spec_helper"

describe Jennifer::SQLite3::CommandInterface do
  described_class = Jennifer::SQLite3::CommandInterface

  describe "#create_database" do
    it do
      schema_rollback do
        interface = described_class.new(Jennifer::Config.config)
        interface.create_database

        if last_command = interface.last_command
          last_command.tap do |command|
            command.executable.should eq("sqlite3")
            command.options.should eq(["./test.db", ""])
            command.in_stream.should be_empty
            command.out_stream.should be_empty
          end
        else
          fail "last_command is nil"
        end
      end
    end
  end

  describe "#drop_database" do
    it do
      schema_rollback do
        interface = described_class.new(Jennifer::Config.config)
        interface.drop_database

        if last_command = interface.last_command
          last_command.tap do |command|
            command.executable.should eq("rm")
            command.options.should eq(["./test.db"])
            command.in_stream.should be_empty
            command.out_stream.should be_empty
          end
        else
          fail "last_command is nil"
        end
      end
    end
  end

  describe "#generate_schema" do
    it do
      schema_rollback do
        interface = described_class.new(Jennifer::Config.config)
        interface.generate_schema

        if last_command = interface.last_command
          last_command.tap do |command|
            command.executable.should eq("sqlite3")
            command.options.should eq(["./test.db", ".schema"])
            command.in_stream.should be_empty
            command.out_stream.should eq(" | grep -v sqlite_sequence > ./spec/support/structure.sql")
          end
        else
          fail "last_command is nil"
        end
      end
    end
  end

  describe "#load_schema" do
    it do
      schema_rollback do
        interface = described_class.new(Jennifer::Config.config)
        Jennifer::Migration::Runner.drop
        Jennifer::Migration::Runner.create
        interface.load_schema

        if last_command = interface.last_command
          last_command.tap do |command|
            command.executable.should eq("sqlite3")
            command.options.should eq(["./test.db"])
            command.in_stream.should eq("cat ./spec/support/structure.sql |")
            command.out_stream.should be_empty
          end
        else
          fail "last_command is nil"
        end
      end
    end
  end
end
