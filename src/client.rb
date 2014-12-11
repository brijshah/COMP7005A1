#!/usr/bin/env ruby 

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    client.rb - A simple TCP client
#--
#-- PROGRAM:        FTP File Transfer Application
#--
#-- FUNCTIONS:      
#--                 def send
#--                 def get
#--                 def list
#--                 def help
#--                 def quit
#--                 def cmdLoop
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- A simple client emulation program for testing servers. The program
#-- implements the following features:
#--     1. Ability to send variable length text strings to the server
#--     2. Number of times to send these strings is user definable
#--     3. Have the client maintain the connection for varying time durations
#--     4. Keep track of how many requests it made to the server, amount of
#--        data sent to the server, amount of time it took for the server to
#--        respond
#--
#-- This program will also allow the user to specify the number of above
#-- clients to spawn via threads. A process is also created that will collect
#-- any statistical data and save it to a file. This is done using UNIX domain
#-- sockets.
#----------------------------------------------------------------------------*/


require 'socket'

#-----------------------------------------------------------------------------
#-- FUNCTION:       def send    
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- send function opens selecte file from the current folder where the
#-- client is run from by prompting for file and locating the filepath.
#-- It then proceeds to send the file to the server and puts a "1" or a "0"  
#-- onto the socket with corresponding message. Terminal displays appropriate
#-- error message if file is not found.    
#----------------------------------------------------------------------------*/
def send
    @s.puts "SEND" 
    listDir = `ls`
    puts "#{listDir.tr "\n"," "}"
    puts "What file do you want to send? "
    fname = gets
    @s.puts fname
    path = `pwd`
    fullpath = "#{path.chomp}/#{fname.chomp}"
    begin
        File.open "#{fullpath.chomp}","rb" do |file|
            data = file.readlines
            @s.puts data
        end
    rescue SystemCallError
        puts "File does not exist. Enter another file: "
        @s.puts "0"
    end
    @s.puts "eof"
    success = @s.gets
        if success == "1"
            puts "File transfer complete. Enter another command: "
        elsif success == "0"
            puts "File transfer failed. Enter another command: "
        end 
end

#-----------------------------------------------------------------------------
#-- FUNCTION:      def get    
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- get function prompts user for a file they want to receive after  
#-- automatically listing folder contents. Puts specified request and 
#-- filename onto socket to send. The funtion then reads the contents of   
#-- the desired file, opens the file and writes data to it. Displays
#-- success message and application continues.   
#----------------------------------------------------------------------------*/
def get
    list
    puts "What file do you want? "
    @s.puts "GET"
    fname = gets
    @s.puts fname

    data = ""
    while 1
        li = @s.gets
        break if li.include? "eof"
        data << li
    end
    path = `pwd`
    fd = File.open "#{path.chomp}/#{fname.chomp}","wb"
    fd.print data
    fd.close
    puts "File received. Enter another command: "    
end

#-----------------------------------------------------------------------------
#-- FUNCTION:      def list    
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- list function puts the specified command on the socket. It 
#-- proceeds to list all files located on the remote server and displaying
#-- it on the client terminal for user to select.     
#----------------------------------------------------------------------------*/
def list
    @s.puts "LIST"
    msg = ""
    while line = @s.gets
        if line.chomp.eql? "end"
            break
        end
        msg += line 
    end
    puts "#{msg.tr "\n"," "}"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:      def help    
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- help function displays list of commands on startup for user to select from    
#----------------------------------------------------------------------------*/
def help
    puts "Enter one of the following: LIST, SEND, GET, QUIT"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:      def quit   
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- quit function terminates session by user request. It places quit 
#-- command onto socket following a messaging saying it has disconnected.   
#----------------------------------------------------------------------------*/
def quit
    @s.puts "QUIT"
    puts "Disconnecting from server."
end 

#-----------------------------------------------------------------------------
#-- FUNCTION:      def cmdloop    
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- cmdloop function captures input from user and and runs  
#-- corresponding function based on input. If user enters
#-- invalid command, terminal displays appropriate message.   
#----------------------------------------------------------------------------*/
def cmdloop
    while 1
        cmd = gets.chomp.strip.downcase
        case cmd
        when "list"
            list
        when "send"
            send
        when "get"
            get
        when "help"
            help
        when "quit"
            quit
            break
        else 
            puts "invalid command"
        end 
    end
end



#connect to to server
puts "Enter the IP address you want to connect to: "
ip = STDIN.gets.chomp
@s = TCPSocket.open(ip, 7005)


puts @s.gets.chomp
puts @s.gets.chomp


cmdloop

@s.close
