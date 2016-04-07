module AwsSdkCodeGenerator
  class HashFormatter

    # @param [Boolean] wrap (true) When `true`, the formatted hash will
    #   be wrapped with curly braces.
    #
    # @param [Boolean] inline (false) When `true` the formatted hash will
    #   contain no newlines.
    #
    # @param [Boolean] quote_strings (false) By default, all hash string values
    #   must contain their own quotes. If you pass `true`, then all hash string
    #   values will be inspected via `#inspect` which will auto-quote them.
    #
    def initialize(wrap:true, inline:false, quote_strings:false)
      @wrap = wrap
      @inline = inline
      @quote_strings = quote_strings
    end

    def format(obj)
      result = hash(obj, i:'', inline:@inline)
      result = result[1..-2] unless @wrap
      result = result.strip if @inline && result.lines.length == 1
      result
    end

    private

    def value(obj, i:, inline:)
      case obj
      when Hash then hash(obj, i:i, inline:inline)
      when Array then array(obj, i:i)
      when String then @quote_strings ? obj.inspect : obj
      when Fixnum, true, false then obj.inspect
      else raise ArgumentError, "unsupported value `#{obj.class}'"
      end
    end

    def hash(hash, i:, inline:)
      if hash.empty?
        '{}'
      elsif inline_hash?(hash, inline)
        inline_hash(hash)
      else
        multiline_hash(hash, i:i)
      end
    end

    def inline_hash(hash)
      "{ #{hash_entry(hash.keys[0], hash.values[0], i:'')} }"
    end

    def multiline_hash(hash, i:)
      str = "{\n"
      hash.each.with_index do |(key, value), n|
        str += "#{i}  #{hash_entry(key, value, i:i)}"
        str += "," unless n == hash.keys.length - 1
        str += "\n"
      end
      str + "#{i}}"
    end

    def hash_entry(key, value, i:)
      value = value(value, i: i + '  ', inline:false)
      if Symbol === key
        "#{key}: #{value}"
      else
        "#{key.inspect} => #{value}"
      end
    end

    def array(array, i:)
      if array.empty?
        '[]'
      elsif inline_array?(array)
        "[#{value(array[0], i:i, inline:true)}]"
      else
        format_multiline_array(array, i:i)
      end
    end

    def format_multiline_array(array, i:)
      str = "[\n"
      array.each.with_index do |value, n|
        str += "#{i}  #{value(value, i:i + '  ', inline:true)}"
        str += "," unless n == array.length - 1
        str += "\n"
      end
      str + "#{i}]"
    end

    def inline_hash?(hash, inline)
      hash.length == 1 && String === hash.values[0] && inline
    end

    def inline_array?(array)
      array.length == 1# && String === array[0]
    end

  end
end
