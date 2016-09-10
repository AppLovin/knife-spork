require 'knife-spork/runner'

class Foo; end

module KnifeSpork
  module Runner 
    describe 'spork_config' do
      before(:each) do 
        Foo.send(:include, KnifeSpork::Runner) 
      end
      
      let(:command) do 
        Foo.new.tap do |i| 
        @config1 = Tempfile.new('spork-config1.yml')
        @config1.write(<<-EOF)
plugins:
  some: value
        EOF
        @config1.close

        @config2 = Tempfile.new('spork-config2.yml')
        @config2.write(<<-EOF)
plugins:
  hello: world
        EOF
        @config2.close

          allow(i).to receive(:load_paths).and_return([@config1.path, @config2.path])
        end
      end

      it 'combines configurations' do
        expect(command.spork_config.plugins.hello).to eq('world')
        expect(command.spork_config.plugins.some).to eq('value')
      end
    end
  end
end
