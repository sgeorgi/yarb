require_relative '../spec_helper'

describe Store do

  it 'uses path for current environment' do
    expect( Store::path ).to eq( File.join( Rails.root, 'db', Rails.env ) )
  end

  context 'included in any class' do

    class MyClass < Struct.new(:my_field)
      include Store
      key_method :my_field
    end

    let(:object) { MyClass.new('my object') }

    it 'uses the name of the base-class for pstore-files' do
       expect( object.send(:store_path) ).to eq( File.join(Store::path, 'my_class' ) )
    end

    it 'saves and retrieves an object from the store' do
      object.save
      read_object = MyClass.find( object.key )
      assert read_object == object, 'Should read the same object as stored'
      expect(read_object.my_field).to eq( 'my object' )
    end

    it 'deletes the store' do 
      object.save
      MyClass.delete_store!
      expect( File.exist?(MyClass.send(:store_path)) ).to be_false
    end

    context 'with two objects' do
      before :each do
        MyClass.delete_store!
        @object1 = MyClass.create('First Object')
        @object2 = MyClass.create('Second Object')
      end

      it 'creates and lists available objects' do
        expect(MyClass.keys).to eq(['First Object', 'Second Object'])
      end

      it 'loads all objects' do
        expect(MyClass.all).to eq( [@object1,@object2] )
      end
    end
  end

end
