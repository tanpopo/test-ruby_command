require "open3"

$home_dir ="/home/marikoyos"
$patch_dir = $home_dir + "/wk/2015-15/patches"
mapping_dir = $patch_dir + "/issue-mapping"

target_dir=$home_dir + "/wk0/aosp/master/frameworks/base/"
target_branch="lollipop-mr1-release"
target_commit="8fba7e6931245a17215e0e740e78b45f6b66d590"
target_Change_Id="I32e238e53ac4b6dd0ae6de226b98894c495b256f"

puts "mapping_dir=" + mapping_dir

o, s = Open3.capture2("factor", :stdin_data=>"42")
p o #=> "42: 2 3 7\n"

o, s = Open3.capture2("pwd", :chdir=>mapping_dir)
puts "pwd:" + o

s = "hello, world"
s.sub!(/\w+/) {|word| word.upcase }
puts s

line = "From cba6174ab03bb7dda6de82c7fc6a98f61b27397e Mon Sep 17 00:00:00 2001"
puts "match test!"
p line.match(/From ([a-z|0-9]+)/)


#begin
#    File.foreach("/home/marikoyos/wk/2015-15/patches/android-5.1.1_r13/frameworks/av/0009-DO-NOT-MERGE-libstagefright-sanity-check-si.bulletin.patch") do |line|
#      puts "****" + linehome_dir

#o, s = Open3.capture2("git branch -a", :chdir=>target_dir)
#o.encode('utf-8', :universal_newline => true)q
#p o

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

def get_branch_from_path(patch_path)
  path = $home_dir + $patch_dir;
  str = patch_path.match(/#{path}\/([^\/]*)\/(.+)/)
  p str
end

####################################################

branch_list = {"android-5.0" => "kitkat-mr2.2-release", "android-5.1" => "lollipop-mr1-release"}
vul_list = Dir::entries(mapping_dir)
puts "vul_list: size=" + vul_list.size.to_s
puts vul_list

for vul in vul_list do
  patch_files = get_patch_files(mapping_dir + "/" + vul)
  puts "patch_files: size=" + patch_files.size.to_s
  puts patch_files

  #get info from patch file
  for patch_path_rel in patch_files do
    patch_path = $patch_dir + "/" + patch_path_rel
    patch_path.sub!(/\.\//,"")
    patch_path.strip!
    change_info = get_change_info(patch_path)
    puts "change_info:"
    p change_info
    branch_dir, project_dir = get_branch_from_path(patch_path)
    branch_dir = "androit-5.0.1_r1"
    str = branch_dir.match(/(android-[0-9]+-[0-9]+)/)
    p "branch dir"
    p str
    remote_branch = branch_list[branch_dir]
  end
end

####################################################

Open3.popen3("git checkout " + target_branch, :chdir=>target_dir) do |i, o, e, w|
  i.close
  o.each do |line| p line end
  e.each do |line| p line end
  p w.value
end

Open3.popen3("git tag --contains " + target_commit, :chdir=>target_dir) do |i, o, e, w|
  i.close
  o.each do |line| p line end
  e.each do |line| p line end
  p w.value
end

Open3.pipeline("git log " + target_commit, "grep "+ target_Change_Id, :chdir=>target_dir) do |i, o, e, w|
  i.close
  o.each do |line| p line end
  e.each do |line| p line end
  p w.value
end
