require 'spec_helper'

describe "bundle pristine", :focused => true do
  context 'given a bundle has been installed' do
    before(:each) do
      build_git "foo"

      gemfile = <<-G
        source "file://#{gem_repo1}"

        gem "rack", '1.0.0'
        gem "foo", "1.0", :git => "#{lib_path('foo-1.0')}"
      G

      install_gemfile(gemfile, :path => "vendor/bundle")
    end

    let(:rack_file) { installed_gem_path_to("rack") + "lib/rack.rb" }
    let(:foo_file)  { installed_git_gem_path_to("foo") + "lib/foo.rb" }
    let!(:original_rack_file_content) { File.read(rack_file) }
    let!(:original_foo_file_content)  { File.read(foo_file) }

    def edit_rack_file
      File.open(rack_file, 'w') { |f| f.write "RACK = '2.0.0.pre'" }
    end

    def edit_foo_file
      File.open(foo_file, 'w') { |f| f.write "FOO = '2.0.0.pre'" }
    end

    it 'restores the installed gems to their original state' do
      edit_rack_file
      File.read(rack_file).should_not == original_rack_file_content
      bundle :pristine
      File.read(rack_file).should == original_rack_file_content
    end

    it 'restores the installed git gems to their original state' do
      edit_foo_file
      File.read(foo_file).should_not == original_foo_file_content
      bundle :pristine
      File.read(foo_file).should == original_foo_file_content
    end
  end
end
