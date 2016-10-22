#!/usr/bin/env ruby

require 'green_shoes'
require 'openssl'
require 'digest/md5'
require 'base64'

Shoes.app title:"Crypto Magic" ,:width=>500, :height=>360 do
#background "#8e0e00".."#1f1c18"
background "#a73737".."#7a2828"

flow :width=> '100%'  do
stack :width=> '480' do
title "CryptoMagic" ,align:'center' , stroke:"#ea384d"
subtitle "Folder Data Encryptor\n", align:'center' , underline:'single'
        end
  
  stack :width=> '20' do
	  @help=button '?'
	  @help.click do window do
para '
	This program uses AES-128-CBC Encryption to encrypt
	all the files of the selected folder.
	It will generate the KeyFile in the encrypted folder.
	You should move this keyfile from the folder and store it
	somewhere safe.

	When you want to decrypt your files simply put the KeyFile
	back in the encrypted folder , Enter your password and click
	on Decrypt button

	The Tool has an inbuilt IV so you gotta protect the KeyFile.
	Its best if u make a copy of the KeyFile itself
	' end end
  end
  
stack :width=>150 do
@folder=button "Select the Folder";
para "\n\n"
para  'Password'
end

stack :width=>350 , :height=> 130 do
@loca= para "No Folder Selected\n\n"
para ''
@folder.click {@loc=ask_open_folder;@loca.replace @loc.split('/')[-1]+"\n\n"}
@pass=edit_line :width => 240
end

stack :width=> 230 do
para ''
@enc=button "Encrypt Files" , width:'100%'
@enc.click {encr(@loc,@pass.text())}
end

stack :width=>240 do
para ''
@dec=button "Decrypt Files", width:'100%'
@dec.click {decr(@loc,@pass.text())}
end

end

def encr(x,y)
if y=='' or x==nil
	alert('Fields can\'t be Blank')
else
cipher=OpenSSL::Cipher::AES.new(128, :CBC)
cipher.encrypt
cipher.key=Digest::MD5.hexdigest(y)
cipher.iv=Digest::MD5.hexdigest(y+'Iv')

Dir.glob("#{x}/**/*") do |files|
begin

data=Base64.encode64(cipher.update(File.read(files)) + cipher.final)
File.write(files,data)
cipher.reset
rescue
next
#RESCUE END
end
#DIR.glob end
end
#WRITE KEY FILE
File.write("#{x}/KeyFile",Digest::MD5.hexdigest(y))
alert('Done Encrypting. make sure you save the KeyFile')
#IF END
end
#DEF ENCR ENDEND
end


def decr(x,y)
	hash=File.read("#{x}/KeyFile") if File.exists?("#{x}/KeyFile")

if y=='' or x==nil
    alert('Fields can\'t be Blank')
elsif !File.exists?("#{x}/KeyFile")
    alert('KeyFile Not Found')
elsif (Digest::MD5.hexdigest(y)!=hash)
    alert('INVALID PASSWORD OR WRONG KEYFILE')
else
	decipher=OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key=hash
    decipher.iv=Digest::MD5.hexdigest(y+'Iv')
    
    Dir.glob("#{x}/**/*") do |files|
    begin
	ddata=Base64.decode64(File.read(files))
	ddata=decipher.update(ddata) + decipher.final
	File.write(files,ddata)
	decipher.reset
	rescue
        next
    end
#DIR GLOB END
end
    File.delete("#{x}/KeyFile")
alert('Decryption Done')
#IF End
end
#DEF END
end
#SHOES END
end
