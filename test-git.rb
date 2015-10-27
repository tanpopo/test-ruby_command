require "open3"

# factorコマンドで与えられた数値(42)を素因数分解する。
o, s = Open3.capture2("factor", :stdin_data=>"42")
p o #=> "42: 2 3 7\n"

o, s = Open3.capture2("pwd", :chdir=>"/home/mariko")
p o

target_dir="/home/mariko/wk0/aosp/master/frameworks/base/"
target_branch="lollipop-mr1-release"
target_commit="8fba7e6931245a17215e0e740e78b45f6b66d590"
target_Change_Id="I32e238e53ac4b6dd0ae6de226b98894c495b256f"

#o, s = Open3.capture2("git branch -a", :chdir=>target_dir)
#o.encode('utf-8', :universal_newline => true)
#p o


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
