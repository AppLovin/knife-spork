module KnifeSpork 
  module Utils
    OBJECT_DELIMITER = "#"

    def self.hash_set_recursive(full_attr, to, hash, create_if_missing = false, append = false) 
      *levels, attr = full_attr.split(OBJECT_DELIMITER)
      parent_hash = levels.inject(hash) do |acc, obj|
      
        if acc.class == Hash and ! acc.has_key? obj 
          acc[obj] = {} 
        elsif acc[obj].class == String
          acc[obj] = {}  
        end

        acc[obj]
      end

      if append and parent_hash.has_key? attr and parent_hash[attr].class == Array
        parent_hash[attr] = parent_hash[attr] + to
      else
        parent_hash[attr] = to
      end

      hash
    end   

    def self.hash_unset(full_attr, hash)
      *levels, attr = full_attr.split(OBJECT_DELIMITER)
      levels.inject(hash, :fetch).delete attr

      hash
    end
  end
end
