local lfs = require "lfs"

function is_dir(path)

   local success, attr = pcall(lfs.attributes, path)

   if not success then
      return false
   end

   if type(attr) ~= "table" then
      return false
   end

   return attr.mode == "directory"

end
