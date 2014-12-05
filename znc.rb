#!/usr/bin/env ruby

require 'fileutils'
require 'tempfile'

FileUtils.mkdir_p "#{ENV['STACKATO_FILESYSTEM']}/configs"
unless File.exists? "#{ENV['STACKATO_FILESYSTEM']}/configs/znc.conf"
    FileUtils.cp '/app/znc.conf' "#{ENV['STACKATO_FILESYSTEM']}/configs/znc.conf"
end

Tempfile.open 'znc.conf' do |temp|
    open "#{ENV['STACKATO_FILESYSTEM']}/configs/znc.conf" do |conf|
        pause = false
        conf.each_line do |line|
            if line.start_with? '<Listener '
                pause = true
            end
            temp.write(line) unless pause
            if line.start_with? '</Listener>'
                pause = false
            end
        end
    end
    temp.write(<<-EOF.gsub(/^\s+/, ''))
        <Listener web>
            Port = #{ENV['PORT']}
            IPv4 = true
            IPv6 = true
            SSL = false
            AllowIRC = false
            AllowWeb = true
        </Listener>
        <Listener irc>
            Port = #{ENV['STACKATO_HARBOR']}
            IPv4 = true
            IPv6 = true
            SSL = false
            AllowIRC = false
            AllowWeb = true
        </Listener>
    EOF
    temp.close
    FileUtils.cp temp.path, "#{ENV['STACKATO_FILESYSTEM']}/configs/znc.conf"
end
exec '/app/bin/znc', '--foreground', '--debug', '--no-color', '--datadir', ENV['STACKATO_FILESYSTEM']
