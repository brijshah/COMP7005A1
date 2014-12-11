#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    server.rb - A simple TCP server
#--
#-- PROGRAM:        FTP File Transfer Application
#--
#-- FUNCTIONS:      
#--                 def receive(client)
#--                 def send(client)
#--                 def list(client)
#--
#-- DATE:           September 24, 2014
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- A simple client application that connects to a server. The program
#-- implements the following features:
#--     1. Initiates a connection to a remote server
#--     2. Issues commands to the server to either send or receive a file
#--     3. Supplies the server information through command line arguments
#--     
#--        
#--        
#--
#-- 
#-- 
#-- 
#-- 
#----------------------------------------------------------------------------*/


require 'socket'

#-----------------------------------------------------------------------------
#-- FUNCTION:       def receive(client)    
#--
#-- DATE:           September 24, 2014
#--
#-- VARIABLE(S):    client is a socket used for all data transfers 
#-- 
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- receive function receives a file that client has chosen to 
#-- send to the server by retreiving the filename from the socket
#-- then assigning the data of the file to a variable line by line,   
#-- the file is then opened and the contents are written to the file.    
#----------------------------------------------------------------------------*/
def receive(client)
    fname = client.gets
    data = ""
    while 1
        line = client.gets
        break if line.include? "eof"
        data << line
    end
    path = `pwd`
    File.open "#{path.chomp}/#{fname.chomp}","wb" do |file|
        file.print data
    end
    
    client.puts "1"
    puts "#{@remote_ip} RECEIVED #{fname.chomp}"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def send(client)    
#--
#-- DATE:           September 24, 2014
#--
#-- VARIABLE(S):    client is a socket used for all data transfers 
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- send function opens the identified file from the folder the server is
#-- located in and sends to the appropriate client by locating the path
#-- of the file and writes it. An appropriate message is displayed depending   
#-- one if the file transfered or not.   
#----------------------------------------------------------------------------*/
def send(client)
    fname = client.gets
    begin 
        path = `pwd`
        fullpath = "#{path.chomp}/#{fname.chomp}"
        File.open "#{fullpath.chomp}","rb" do |file|
            data = file.readlines
            client.puts data
        end
        client.puts "eof"
        puts "#{@remote_ip} TRANSFERED #{fname.chomp}"
    rescue SystemCallError
        puts "File does not exist." 
    end
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def list(client)    
#--
#-- DATE:           September 24, 2014
#--
#-- VARIABLE(S):    client is a socket used for all data transfers 
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- list function simply sends a listing of the files located within the
#-- directory to client by using the "ls" command  
#----------------------------------------------------------------------------*/
def list(client)
    client.puts `ls`
    client.puts "end"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def cmdLoop(client)    
#--
#-- DATE:           September 24, 2014
#--
#-- VARIABLE(S):    client is a socket used for all data transfers 
#-- 
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- cmdLoop function retreives command from client-based on the command
#-- received the corresponding function is called to proceed with the 
#-- transfer. When the client initiates a command - the server prints the   
#-- clients IP address along with the command they intended.   
#----------------------------------------------------------------------------*/
def cmdLoop(client)
     while msg = client.gets.chomp
        puts "#{@remote_ip} #{msg}"
        case msg
        when "LIST"
            list client
        when "QUIT"
            break
        when "GET"
            send client
        when "SEND"
            receive client
        else 
            puts msg
        end
    end
end



server = TCPServer.open(7005)
loop do
    Thread.start(server.accept) do |client|
        sock_domain, remote_port, 
            remote_hostname, @remote_ip = client.peeraddr
        client.puts "File Transfer Client"
        client.puts "Enter HELP for available commands."
        puts "#{@remote_ip} has connected"
        cmdLoop(client)
        puts "#{@remote_ip} has disconnected"
        client.close        
    end
end