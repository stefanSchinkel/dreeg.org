#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
	Purpose:
		A thin wrapper for renaming EEG data from BrainVision 
		Analyser and rewriting .vhdr and .vrmk files. 
		It simply replaces a given subjectCode with a 
		new subject code. Oh, and it works in-place, so have your
		RCS up and running. Just in case :o)
		
	Requirements:
		none
		
	* Copyright (c) 2012, Stefan Schinkel, HU Berlin
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without
	* modification, are permitted provided that the following conditions are met:
	*     * Redistributions of source code must retain the above copyright
	*       notice, this list of conditions and the following disclaimer.
	*     * Redistributions in binary form must reproduce the above copyright
	*       notice, this list of conditions and the following disclaimer in the
	*       documentation and/or other materials provided with the distribution.
	*     * Neither the name of the HU Berlin nor the
	*       names of its contributors may be used to endorse or promote products
	*       derived from this software without specific prior written permission.
	*
	* THIS SOFTWARE IS PROVIDED BY Stefan Schinkel ''AS IS'' AND ANY
	* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	* DISCLAIMED. IN NO EVENT SHALL Stefan Schinkel BE LIABLE FOR ANY
	* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""

__version__ = "0.01"

#Imports
import sys,os,re,glob


##########################
##		Functions 		##
##########################
def getInput():
	try: 
		oldCode = sys.argv[1] 
		newCode = sys.argv[2] 
		
	except IndexError:
			print "This is bvaRewrite Version: %s" % __version__
			print "ERROR: No/not enough codes given!"
			print "Calling convention: bvaRewrite oldCode newCode" 	
			print "And by the way, I work in-place :o)"	
			exit(-1)
	
	return(oldCode,newCode)
		
def getHeaderFiles(codeOld):

	"""
	get all BVA headers matching the old code,
	simply is: ls `*oldCode*.vhdr`
	"""
	pattern = '*'+codeOld + '*.vhdr'
	headerFiles = glob.glob(pattern)
	
	if len(headerFiles) == 0:
		print "No matches found. Goodbye"
		sys.exit(0)

	return headerFiles
	
def rewriteFile(fileOld,fileNew,strOld,strNew):
	
	"""
	Infile, inline string replacement
	"""
	
	print "Rewriting %s to %s " % (fileOld,fileNew)
	o = open(fileNew,"w")
	data = open(fileOld).read()
	o.write( re.sub(strOld,strNew,data)  )
	o.close()
	
	# explicit removal is required
	os.remove(fileOld)

##########################
##	Implementation		##
##########################

if __name__ == '__main__':


	codes = getInput()
	oldCode = codes[0];	newCode = codes[1];
	
	# get all headerFiles that match the old code
	headerFiles = getHeaderFiles(oldCode)
	
	for hdr in headerFiles:
		
		# rewrite headerfiles 
		rewriteFile(hdr,hdr.replace(oldCode,newCode),oldCode,newCode);
		
		# rewrite markerfiles
		mrk = hdr[:-4] + 'vmrk'
		rewriteFile(mrk,mrk.replace(oldCode,newCode),oldCode,newCode);

		# rewrite markerfiles
		eeg = hdr[:-4] + 'eeg'
		print "Renaming %s to %s" % (eeg,eeg.replace(oldCode,newCode))
		os.rename(eeg,eeg.replace(oldCode,newCode))

	# say goodbye
	print "All done. Have a nice day"


