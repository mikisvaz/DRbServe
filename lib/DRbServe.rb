require 'drb'
require 'fileutils'
module DRbServe

  def uri_filename=(filename)
    @uri_filename = filename
  end

  def uri_filename
    @uri_filename ||= File.join('/tmp', "DRbServe" + self.to_s + ".uri")
    @uri_filename 
  end


  def uri=(uri)
    puts "Saving #{ uri } in #{ self.uri_filename }"
    FileUtils.mkdir_p FileUtils.dirname(uri_filename) unless File.exist? File.dirname(uri_filename)
    fout = File.open(uri_filename,'w')
    fout.puts uri
    fout.close
  end

  def uri
    File.open(uri_filename).read
  end

  def start_server
    if Class === self
      o = self.new
    else
      o = self
    end

    class << o
      def alive
        true
      end
    end

    DRb.start_service nil, o
    self.uri= DRb.uri
    puts uri
    DRb.thread.join
  end

  def hook
    if File.exist? uri_filename
      begin
        @remote = DRbObject.new(nil, uri)
        puts "Connected to #{ uri }" if @remote.alive
        @served ||=[]
        @served.each{|method_name|
          class << self; self; end.instance_eval{
            define_method(method_name, 
              proc{|*args| 
                  @remote.send(method_name, *args)
            })
          }
        }
      rescue
      end
    end
  end

  def serve(method)
    @served ||= []
    @served << method
  end

end


