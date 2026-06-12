# -*- encoding: utf-8 -*-
require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Kernel#chop" do
  it "is a private method" do
    KernelSpecs.private_instance_method?(:chop).should == true
  end

  it "removes the final character of $_" do
    KernelSpecs.chop("abc").should == "ab"
  end

  it "removes the final carriage return, newline of $_" do
    KernelSpecs.chop("abc\r\n").should == "abc"
  end
end

describe "Kernel#chop" do
  before :each do
    @external = Encoding.default_external
    Encoding.default_external = Encoding::UTF_8
  end

  after :each do
    Encoding.default_external = @external
  end

  it "removes the final multi-byte character from $_" do
    script = fixture __FILE__, "chop.rb"
    KernelSpecs.run_with_dash_n(script).should == "あ"
  end
end

describe "Kernel.chop" do
  it "is a public method" do
    KernelSpecs.public_singleton_method?(:chop).should == true
  end
end
