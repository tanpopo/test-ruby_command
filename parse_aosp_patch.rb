require "open3"



#begin
#    File.foreach("/home/marikoyos/wk/2015-15/patches/android-5.1.1_r13/frameworks/av/0009-DO-NOT-MERGE-libstagefright-sanity-check-si.bulletin.patch") do |line|
#      puts "****" + linehome_dir

#o, s = Open3.capture2("git branch -a", :chdir=>target_dir)
#o.encode('utf-8', :universal_newline => true)q
#p o

class AospPatchParser
  def initialize(my_home_dir)
    @home_dir = my_home_dir
    @patch_dir = @home_dir + "/wk/2015-15/patches"
    @mapping_dir = @patch_dir + "/issue-mapping"

    @target_dir=@home_dir + "/wk0/aosp/master"

    @target_branch="lollipop-mr1-release"
    @target_commit="8fba7e6931245a17215e0e740e78b45f6b66d590"
    @target_Change_Id="I32e238e53ac4b6dd0ae6de226b98894c495b256f"

    @branch_list = {
      "android-4.4.4_r2.0.1" => "android-4.4.4_r2.0.1"
      "android-5.0" => "lollipop-mr1-release",
      "android-6.0" => "marshmallow-release"
    }

  end

  def init()
    p "AospPatchParser.init"
  end

  # return patch file list from ANDROID-XXXX file
  def get_patch_files(filepath)
    files = Array.new
    p "=========="
    p "patch file for vul: " + filepath
    begin
      File.foreach(filepath) do |line|
  #      p "patch-> " + line
        files.push(line)
      end
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}])
    end
    return files
  end

  # get commit-id, Change-Id, ... from patch file
  def get_change_info(filepath)
    info = Hash::new
    info['filepath'] = filepath #[todo] get only filepath
  p "=========="
  p "patch file: " + filepath
  begin
  #  puts "patch file: " + filepath
    File.foreach(filepath) do |line|
  #    p "***" + line
      line.strip!
      #p line.match(/From ([a-z|0-9]+)/)
      if str = line.match(/^From ([a-z|0-9]+)/)
        info['commit-id'] = str[1]
      elsif str = line.match(/^Change-Id: ([a-z|A-Z|0-9]+)/)
        info['Change-Id'] = str[1]
      elsif str = line.match(/^Subject: (.+)$/)
        info['Subject'] = str[1]
        subject = str[1]
        info['comment'] = str[1]
      end
    end
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}])
    end
    return info
  end

  def get_branch_from_path(patch_path_abs)
    path = @home_dir + @patch_dir;
    str = patch_path.match(/#{path}\/([^\/]*)\/(.+)/)
    p str
  end

#input: relative_path in ANDROID-XXX file
  def get_branch_from_relpath(patch_path_rel)
    str = patch_path_rel.match(/\.\/([^\/]+)\/([^0-9]+)(.*)/)
    p "get_branch_from_relpath str:"
    p str
    return str[1], str[2].chop!, str[3]
  end

  def get_vul_files(dir)
    vul_list = Array.new;
    entries = Dir::entries(dir)
    p "entries:"
    p entries
    for entry in entries do
      if !entry.match(/^\./)
        vul_list.push(entry)
      end
    end
    return vul_list
  end

  def get_project_log(project_dir)
    logs = Hash.new

    Open3.popen3("git log", :chdir=>project_dir) do |i, o, e, w|
      i.close
      o.each do |line|
        p line

        if str = line.match(/commit ([a-z|0-9]+)/)
          log['commit-id'] = str[1]
          comment_start = false;
        elsif str = line.match(/Date: (.+)$/)
          log['Date'] = str[1].strip!
          comment_start = true
          log['comment'] = ""
        end

        if comment_start
          if str = line.match(/Change-Id: ([a-z|A-Z|0-9]+)/)
            log['Change-Id'] = str[1]
          end
          log['comment'] += line
        end

      end
      e.each do |line| p line end
      p w.value
    end
    return logs
  end

  def get_tags_for_vul_by_changeId(branch_dir, changeId)
    tags = Array.new

    project_dir = @repo_dir + "/" + branh_dir

    Open3.popen3("git checkout " + @target_branch, :chdir=>project_dir) do |i, o, e, w|
      i.close
      o.each do |line| p line end
      e.each do |line| p line end
      p w.value
    end

    logs = get_project_log(working_dir)
    for log in logs do
      if logs['Change-Id'].match(#{changeId})
        commit_id = logs['commit-id']
      end
    end

    end
    Open3.popen3("git tag --contains " + commit_id, :chdir=>project_dir) do |i, o, e, w|
      i.close
      o.each do |line|
        p line
        tags.push(line.strip!)
      end
      e.each do |line| p line end
      p w.value
    end
    return tags
  end

  def output_tags_for_vul()

    vul_list = get_vul_files(@mapping_dir)
    puts "vul_list: size=" + vul_list.size.to_s
    puts vul_list

    for vul in vul_list do
      patch_files = get_patch_files(@mapping_dir + "/" + vul)
      puts "patch_files: size=" + patch_files.size.to_s
      puts patch_files

      #get info from patch file
      for patch_path_rel in patch_files do
        patch_path = @patch_dir + "/" + patch_path_rel
        patch_path.sub!(/\.\//,"")
        patch_path.strip!
        change_info = get_change_info(patch_path)
        puts "change_info:"
        p change_info

        patch_path_rel = "./android-4.4.4_r2.0.1/bootable/recovery/0001-XXXXX"
        patch_path_rel = "./android-6.0/system/core/0001-libXX"
        branch_dir, project_dir, patch_file = get_branch_from_relpath(patch_path_rel)

        branch_name = branch_list[branch_dir]

        tags = get_tags_for_vul(branch_name, change_info['Change-Id'], change_info['commit-id'])
      end
    end
  end #output_tags_for_vul

  def test()
    o, s = Open3.capture2("pwd", :chdir=>@mapping_dir)
    puts "pwd:" + o

    Open3.popen3("git checkout " + @target_branch, :chdir=>@target_dir) do |i, o, e, w|
      i.close
      o.each do |line| p line end
      e.each do |line| p line end
      p w.value
    end

    Open3.popen3("git tag --contains " + @target_commit, :chdir=>@target_dir) do |i, o, e, w|
      i.close
      o.each do |line| p line end
      e.each do |line| p line end
      p w.value
    end

    Open3.pipeline("git log " + @target_commit, "grep "+ target_Change_Id, :chdir=>@target_dir) do |i, o, e, w|
      i.close
      o.each do |line| p line end
      e.each do |line| p line end
      p w.value
    end
  end

end # class

####################################################


o, s = Open3.capture2("factor", :stdin_data=>"42")
p o #=> "42: 2 3 7\n"

s = "hello, world"
s.sub!(/\w+/) {|word| word.upcase }
puts s

parser = AospPatchParser.new("/home/mariko");
parser.output_tags_for_vul();
