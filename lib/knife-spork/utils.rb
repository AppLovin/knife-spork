module KnifeSpork 
  module Utils
    OBJECT_DELIMITER = "#"

    def self.hash_set_recursive(attr, to, hash, create_if_missing = false) 
      if ! attr.include? OBJECT_DELIMITER
        hash[attr] = to
      else 
        head, *tail = attr.split(OBJECT_DELIMITER)
        if ! hash[head].nil? && hash[head].class != String
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, hash[head], create_if_missing = create_if_missing) 
        elsif hash[head].class == String
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = create_if_missing) 
        elsif create_if_missing
          hash[head] = hash_set_recursive(tail.join(OBJECT_DELIMITER), to, {}, create_if_missing = true) 
        end 
      end

      hash
    end   
  end
end
