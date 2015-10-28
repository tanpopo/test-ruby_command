require 'test/unit'
require './parse_aosp_patch'

class TestParseAospPatch < Test::Unit::TestCase
  class << self
    def startup
      p :_startup
    end

    # テスト群の実行後に呼ばれる
    def shutdown
      p :_shutdown
    end
  end

  # 毎回テスト実行前に呼ばれる
  def setup
    @parser = AospPatchParser.new("/home/marikoyos")
  end

  # テストがpassedになっている場合に，テスト実行後に呼ばれる．テスト後の状態確認とかに使える
  def cleanup
    p :cleanup
  end

  # 毎回テスト実行後に呼ばれる
  def teardown
    p :treadown
  end

  def test_get_branch_from_relpath
    patch_path_rel = "./android-4.4.4_r2.0.1/bootable/recovery/0001-XXXXX"
    branch_dir, project_dir, patch_file = @parser.get_branch_from_relpath(patch_path_rel)
    puts "branch_dir=" + branch_dir;
    puts "project_dir=" + project_dir;

    assert_match(/^android-4.4.4_r2.0.1$/, branch_dir)
#    assert_match(/^bootable\/recovery\/.*/, project_dir)
    assert_match(/^bootable\/recovery$/, project_dir)

    patch_path = "./android-6.0/system/core/0001-libXX"
  end

end
