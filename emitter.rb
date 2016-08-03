require 'socket.io/emitter/version'
require 'msgpack'
require 'redis'
require "awesome_print"

module SocketIO
  class Emitter
    module Type
      EVENT = 2
      BINARY_EVENT = 5
    end

    FLAGS = %w(json volatile broadcast)

    def initialize(options = {})
      @redis = options[:redis] || Redis.new
      @key = "#{options[:key] || 'socket.io'}#/#";
      @nsp = nil
      @rooms = []
      @flags = {}
    end

    FLAGS.each do |flag|
      define_method(flag) { clone.enable_flag(flag) }
    end

    def in(room)
      clone.add_room(room)
    end
    alias :to :in

    def of(nsp)
      clone.select_namespace(nsp)
    end

    def emit(*args)
      packet = {}
      packet[:type] = has_binary?(args) ? Type::BINARY_EVENT : Type::EVENT
      packet[:data] = args
      packet[:nsp] = @nsp || '/'

      packed = MessagePack.pack(['emitter', packet, { rooms: @rooms, flags: @flags }])
      ap packed
      @redis.publish(@key, packed)

      self
    end

    protected

    def add_room(room)
      @rooms += [room] unless @rooms.include?(room)
      self
    end

    def select_namespace(nsp)
      @nsp = nsp
      self
    end

    def enable_flag(flag)
      @flags = @flags.merge(flag.to_sym => true)
      self
    end

    private

    def has_binary?(args)
      args.select {|x| x.is_a?(String)}.any? {|str|
        str.encoding == Encoding::ASCII_8BIT && !str.ascii_only?
      }
    end
  end
end

# "publish" "socket.io#/#" "\x93\xa7emitter\x83\xa4type\x02\xa4data\x92\xacchat message\xb82016-08-03T09:04:41.412Z\xa3nsp\xa1/\x82\xa5rooms\x90\xa5flags\x80"
#"publish" "socket.io#/#" "\x92\x83\xa4type\x02\xa4data\x92\xacchat message\xa8asdfasdf\xa3nsp\xa1/\x82\xa5rooms\x90\xa5flags\x80"


#require 'socket.io-emitter'

# emitter = SocketIO::Emitter.new(key: 'socket.io/')
emitter = SocketIO::Emitter.new()
emitter.in('1470220443712').emit('chat message', "1470220443712 room")
