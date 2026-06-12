require_relative '../../spec_helper'
require_relative 'fixtures/classes'
require_relative 'shared/sprintf'

describe "Kernel#sprintf" do
  it "is a private method" do
    Kernel.private_instance_methods(false).should.include?(:sprintf)
  end

  it_behaves_like :kernel_sprintf, -> format, *args {
    r = nil
    -> {
      r = sprintf(format, *args)
    }.should_not complain(verbose: true)
    r
  }

  it "calls #to_str to convert the format object to a String" do
    obj = mock('format string')
    obj.should_receive(:to_str).and_return("to_str: %i")
    sprintf(obj, 42).should == "to_str: 42"
  end

  # Keep encoding-related specs in a separate shared example to be able to skip them in IO/File/StringIO specs.
  # It's difficult to check result's encoding in the test after writing to a file/io buffer.
  context "encoding" do
    it "can produce a string with valid encoding" do
      string = sprintf("good day %{valid}", valid: "e")
      string.encoding.should == Encoding::UTF_8
      string.valid_encoding?.should == true
    end

    it "can produce a string with invalid encoding" do
      string = sprintf("good day %{invalid}", invalid: "\x80")
      string.encoding.should == Encoding::UTF_8
      string.valid_encoding?.should == false
    end

    it "returns a String in the same encoding as the format String if compatible" do
      string = "%s".dup.force_encoding(Encoding::KOI8_U)
      result = sprintf(string, "dogs")
      result.encoding.should.equal?(Encoding::KOI8_U)
    end

    it "returns a String in the argument's encoding if format encoding is more restrictive" do
      string = "foo %s".dup.force_encoding(Encoding::US_ASCII)
      argument = "b\303\274r".dup.force_encoding(Encoding::UTF_8)

      result = sprintf(string, argument)
      result.encoding.should.equal?(Encoding::UTF_8)
    end

    it "raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" do
      string = "Ä %s".encode('windows-1252')
      argument = "Ђ".encode('windows-1251')

      -> {
        sprintf(string, argument)
      }.should.raise(Encoding::CompatibilityError)
    end

    describe "%c" do
      it "supports Unicode characters" do
        result = sprintf("%c", 1286)
        result.should == "Ԇ"
        result.bytes.should == [212, 134]

        result = sprintf("%c", "ش")
        result.should == "ش"
        result.bytes.should == [216, 180]
      end

      it "raises error when a codepoint isn't representable in an encoding of a format string" do
        format = "%c".encode("ASCII")

        -> {
          sprintf(format, 1286)
        }.should.raise(RangeError, /out of char range/)
      end

      it "uses the encoding of the format string to interpret codepoints" do
        format = "%c".dup.force_encoding("euc-jp")
        result = sprintf(format, 9415601)

        result.encoding.should == Encoding::EUC_JP
        result.should == "é".encode(Encoding::EUC_JP)
        result.bytes.should == [143, 171, 177]
      end
    end
  end
end

describe "Kernel.sprintf" do
  it "is a public method" do
    Kernel.public_methods(false).should.include?(:sprintf)
  end
end
