module KnifeSpork 
  module Utils
    OBJECT_DELIMITER = "#"

    def self.hash_set_recursive(attr, to, hash, create_if_missing = false, is_array = false) 
      if ! attr.include? OBJECT_DELIMITER
        if is_array & (hash.include? attr)
          hash[attr] = hash[attr] + to
        else
          hash[attr] = to
        end
      else 
        head, *tail = attr.split(OBJECT_DELIMITER)
        if ! hash[head].nil? && hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, hash[head], create_if_missing = create_if_missing, is_array = is_array) 
        elsif ! hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = create_if_missing) 
        elsif create_if_missing
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = true, is_array = is_array) 
        end 
      end

      hash
    end   
  end
end
