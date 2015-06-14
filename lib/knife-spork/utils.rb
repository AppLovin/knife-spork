module KnifeSpork 
  module Utils
    OBJECT_DELIMITER = "#"

    def self.hash_set_recursive(attr, to, hash, create_if_missing = false, array = false) 
      if ! attr.include? OBJECT_DELIMITER
        if array & (hash.include? attr)
          hash[attr] = hash[attr] + to
        else
          hash[attr] = to
        end
      else 
        head, *tail = attr.split(OBJECT_DELIMITER)
        if ! hash[head].nil? && hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, hash[head], create_if_missing = create_if_missing, array = array) 
        elsif ! hash[head].class == Hash
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = create_if_missing) 
        elsif create_if_missing
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = true, array = array) 
        end 
      end

      hash
    end   
  end
end
