module KnifeSpork
  module Utils
    def self.hash_set_recursive(attr, to, hash) 
      if ! attr.include? "."
        hash[attr] = to
      else 
        head, *tail = attr.split(".")
        hash[head] = hash_set_recursive(tail.join("."), to, hash[head])    
      end

      hash
    end   
  end
end
