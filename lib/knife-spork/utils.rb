module KnifeSpork
  module Utils
    def self.hash_set_recursive(attr, to, hash, create_if_missing = false) 
      if ! attr.include? "."
        hash[attr] = to
      else 
        head, *tail = attr.split(".")
        if ! hash[head].nil? 
          hash[head] = hash_set_recursive(tail.join("."), to, hash[head], create_if_missing = create_if_missing) 
        elsif create_if_missing
          hash[head] = hash_set_recursive(tail.join("."), to, {}, create_if_missing = true) 
        end 
      end

      hash
    end   
  end
end
