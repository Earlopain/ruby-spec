# -*- encoding: utf-8 -*-
require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Kernel#chomp" do
  it "is a private method" do
    KernelSpecs.private_instance_method?(:chomp).should == true
  end

  it "removes the final newline of $_" do
    KernelSpecs.chomp("abc\n").should == "abc"
  end

  it "removes the final carriage return of $_" do
    KernelSpecs.chomp("abc\r").should == "abc"
  end

  it "removes the final carriage return, newline of $_" do
    KernelSpecs.chomp("abc\r\n").should == "abc"
  end

  it "removes only the final newline of $_" do
    KernelSpecs.chomp("abc\n\n").should == "abc\n"
  end

  it "removes the value of $/ from the end of $_" do
    KernelSpecs.chomp("abcde", "cde").should == "ab"
  end
end

describe "Kernel#chomp" do
  before :each do
    @external = Encoding.default_external
    Encoding.default_external = Encoding::UTF_8
  end

  after :each do
    Encoding.default_external = @external
  end

  it "removes the final carriage return, newline from a multi-byte $_" do
    script = fixture __FILE__, "chomp.rb"
    KernelSpecs.run_with_dash_n(script).should == "あれ"
  end
end

describe "Kernel.chomp" do
  it "is a public method" do
    KernelSpecs.public_singleton_method?(:chomp).should == true
  end
end
