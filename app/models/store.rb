require 'pstore'

# A Wrapper for PStore
# @example
#   class MyClass
#     include Store
#     key_method :my_unique_key  # Name this method as you like
#
#     def my_unique_key
#       # return a unique key for your object
#     end
#   end
#
#   object = MyClass.new
#   _saved_key = object.key
#   object.save
#   #.... later ....
#   re_read = MyClass.find( _saved_key )
#   # re_read is the same object as before
#   # read from .../db/:env/my_class/my_class.pstore
module Store

  # extend the class with ClassMethods and
  # include InstanceMethods to each object of this class
  def self.included base_class
    base_class.send(:extend,ClassMethods)
    base_class.send(:include,InstanceMethods)
  end

  # @return [String] the path to the data-store for the current environment.
  # @example
  #   .../yarb/db/development
  def self.path
    File.join( Rails.root, 'db', Rails.env )
  end

  # ClassMethods for including class
  module ClassMethods
    
    # Initialize and store new object
    # @param [Array] args - are passed to the initializer of class
    # @return [Object] a new object of class which is saved
    def create *args
      new_object = new(*args)
      new_object.save
      new_object
    end

    # Load object from store
    # @param [String|Symbol] _key - the key of the object to find
    # @return [Object|nil]
    def find _key
      store.transaction(:read_only) { |s| s[_key] }
    end

    # Load all objects
    # @return [Array] of all objects in the store
    def all
      store.transaction(:read_only) { |s| s.roots.map {|r| s[r]} }
    end

    # Define the key-method for this class
    # @example
    #   class MyClass
    #     include Store
    #     key_method :uid
    #     def uid
    #       .....
    #     end
    #   end
    def key_method method
      define_method(:key) { (self.send method) }
    end

    # List all keys
    # @return [Array] array of object-keys
    def keys
      store.transaction(:read_only) { |s| s.roots }
    end

    # Deletes the entire store
    def delete_store!
      FileUtils.remove_dir( self.send(:store_path), :force )
    end

    private

    def store_path
      File.join( Store::path, self.to_s.underscore )
    end

    def class_file
      "#{self.to_s.underscore}.pstore"
    end

    def store
      FileUtils.mkdir_p store_path unless File.exist?(store_path)
      PStore.new File.join( store_path, class_file )
    end

  end

  # Methods to be included by objects of the class
  module InstanceMethods

    # Write object to store-file
    def save
      store.transaction() { |s| s[self.key] = self }
    end

    private

    def store
      self.class.send(:store)
    end

    def store_path
      self.class.send(:store_path)
    end

  end

end
