module KnifeSpork 
  module Utils
    OBJECT_DELIMITER = "#"

    def self.hash_set_recursive(attr, to, hash, create_if_missing = false, append = false) 
      if ! attr.include? OBJECT_DELIMITER
        if append & ! (hash[attr].nil?) & (hash[attr].class == Array)
          hash[attr] = hash[attr] + to
        else
          hash[attr] = to
        end
      else 
        head, *tail = attr.split(OBJECT_DELIMITER)
        attribute_exists = ! hash[head].nil?

        if attribute_exists && hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, hash[head], create_if_missing = create_if_missing, append = append) 
        elsif ! hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = create_if_missing) 
        elsif create_if_missing
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = true, append = append) 
        end 
      end

      hash
    end   

    def self.hash_unset(attr, hash)
      parts = attr.split(OBJECT_DELIMITER)
      levels = parts.slice(0, parts.length - 1)
      attr = parts[-1]
      curr_hash = hash

      levels.each do |lvl|
        if ! curr_hash.has_key? lvl 
          hash
        else
          curr_hash = curr_hash[lvl]
        end 
      end  

      if curr_hash.has_key? attr
        curr_hash.delete(attr) 
      end

      hash
    end
  end
end
