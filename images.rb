require 'find'
require 'pathname'
require 'pp'

def get_file_paths path
  paths = []
  Find.find(path) do |p| 
    path =  Pathname.new(p)
    paths << path unless (path.directory?)
  end
  return paths
end

images_path = Pathname.new('C:\InterSystems\HSFoundation\CSP\acb\LISPages\images')
xmls_paths = {
  fwk: Pathname.new('C:\TFSProject\Roche.DE.FWK_Components\Components2012'),
  code: Pathname.new('C:\TFSProject\Roche.DE.LIS\Development\Omega_4_3_0_D\Cache\ACB'),
}

images = []

# build image hashes array
get_file_paths(images_path).each do |p|
  image_name = p.basename.to_s.force_encoding('utf-8')
  image_path = p.relative_path_from(images_path).to_s
  images << {name: image_name, path: image_path, uses: {fwk: [], code: []}}
end

# check all xmls for image ocurrences
xmls_paths.each do |namespace,path|
  get_file_paths(path).each do |xml_path|
    xml = File.read(xml_path)
    images.map! do |image| 
      if xml.include? image[:name] 
        image[:uses][namespace.to_sym] << xml_path.relative_path_from(path).to_s
      end
      image
    end
  end  
end

puts 'images: total tally:'
PP.pp images  

not_used = []
only_on_css = []
only_on_fwk = []
only_on_code = []
on_both = []
images.each do |i|
  if i[:uses][:code].length == 0 and i[:uses][:fwk].length == 0
    not_used << i[:path]
  elsif i[:uses][:code].length == 0 
    if i[:uses][:fwk] == ["Releases/css_controlCUI.css"] #only used in css
      only_on_css << i[:path]
    else 
      only_on_fwk << i[:path]
    end
  elsif i[:uses][:fwk].length == 0 
    only_on_code << i[:path]
  else
    on_both << i[:path]
  end
end

puts 'images not used= ' + not_used.length.to_s
puts not_used
puts
puts 'images used only on css= ' + only_on_css.length.to_s
puts only_on_css
puts
puts 'images used only on fwk= ' + only_on_fwk.length.to_s
puts only_on_fwk
puts
puts 'images used only on code= ' + only_on_code.length.to_s
puts only_on_code
puts
puts 'images used on both= ' + on_both.length.to_s
puts on_both


