require "win-path-utils/version"

require "win32/registry"

module WinPathUtils
  class Path
    class WrongOptionError < StandardError; end
    class SetxError < StandardError; end

    def initialize(options = {})
      @separator = options[:separator] || ';'

      options[:type] ||= :system
      
      @hkey, @reg_path, @key_name = case options[:type]
      when :system
        [Win32::Registry::HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path']
      when :local, :user
        [Win32::Registry::HKEY_CURRENT_USER, 'Environment', 'PATH']
      else
        raise WrongOptionError, "Unknown type!"
      end

      @hkey     = options[:hkey]     if options.key?(:hkey)
      @reg_path = options[:reg_path] if options.key?(:reg_path)
      @key_name = options[:key_name] if options.key?(:key_name)
    end

    # Sets the entire PATH variable to provided string
    def set(value)
      with_reg do |reg|
        reg[@key_name] = value
      end
    end

    # Returns the entire PATH variable as string
    def get
      with_reg do |reg|
        begin
          reg.read(@key_name)[1]
        rescue Win32::Registry::Error
          nil
        end
      end
    end

    # Sets the entire PATH variable to provided array
    # Joins with @separator
    def set_array(value)
      set(value.join(@separator))
    end

    # Returns the entire PATH variable as array
    # Splits with @separator
    def get_array
      get.split(@separator)
    end

    # Adds value to the path
    def add(value, options = {})
      # Set defaults
      options[:duplication_filter] = :do_not_add unless options.key?(:duplication_filter)

      # Get path
      path = get_array

      # Check duplicates
      if path.member?(value)
        case options[:duplication_filter]
        when :do_not_add, :deny
          # do nothing, we already have one in the list
          return
        when :remove_existing
          path.delete!(value)
        when :none
          # just pass through
        else
          raise WrongOptionError, "Unknown :duplication_filter!"
        end
      end

      # Change path array
      case options[:where]
      when :start, :left
        path.unshift value
      when :end, :right
        path.push value
      else
        raise WrongOptionError, "Unknown :where!"
      end

      # Save new array
      set_array(path)
    end

    # Adds element to the end of the path if not exists
    def push(value, options = {})
      add(value, options.merge(where: :end))
    end
    alias_method :append, :push

    # Adds element to the start of the path if not exists
    def unshift(value, options = {})
      add(value, options.merge(where: :start))
    end
    alias_method :prepend, :unshift

    # Removes the item from the path
    def remove(value)
      path = get_array
      path.delete(value)
      set_array(path)
    end
    alias_method :delete, :remove

    # Checks the inclusion of value in path
    def include?(value)
      get_array.include?(value)
    end
    alias_method :member?, :include?

    # Cause Windows to reload environment from registry
    def self.commit!
      var = "WIN_PATH_UTILS_TMPVAR"

      fd_r, fd_w = IO.pipe
      result = system("setx", var, "", [:out, :err] => fd_w)
      fd_w.close
      output = fd_r.read

      raise SetxError.new("SETX error: #{output}") if result == false

      result
    end

    # Alias
    def commit!
      self.class.commit!
    end

    private

    # Execute block with the current reg settings
    def with_reg(access_mask = Win32::Registry::Constants::KEY_ALL_ACCESS, &block)
      @hkey.open(@reg_path, access_mask, &block)
    end
  end
end
