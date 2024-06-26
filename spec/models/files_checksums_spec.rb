require "spec_helper"

describe "FilesChecksums" do
  def assert_checksum(expected, filename)
    filepath = Rails.root.join(filename)
    checksum = Digest::MD5.hexdigest(File.read(filepath))
    assert checksum.in?(Array(expected)), "Bad checksum for file: #{filename}, local version should be reviewed: checksum=#{checksum}, expected=#{Array(expected).join(" or ")}"
  end

  it "should ensure project patch file is up to date" do
    # 5.1.2 & 4.2.9 checksum (the self.allowed_to_condition method is completely overridden and should be reviewed if this test breaks)
    assert_checksum %w(c31728315eed8b65e2e906c264a1a8ae b8ce67efe695bc2381e56db07a0a889e a11cce5462e20a51064f9a72834ac527), "app/models/project.rb"
  end

end
