#!/bin/bash -l
#
# Keeping an executable called processBETA, but with a warning that
# we've moved on to processASKAP.
#  For now, we will run processASKAP from here, but this won't always
#  be the case.
#
# @copyright (c) 2017 CSIRO
# Australia Telescope National Facility (ATNF)
# Commonwealth Scientific and Industrial Research Organisation (CSIRO)
# PO Box 76, Epping NSW 1710, Australia
# atnf-enquiries@csiro.au
#
# This file is part of the ASKAP software distribution.
#
# The ASKAP software distribution is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# @author Matthew Whiting <Matthew.Whiting@csiro.au>
#

if [ "${PIPELINEDIR}" == "" ]; then
    
    echo "ERROR - the environment variable PIPELINEDIR has not been set. Cannot find the scripts!"

else 

    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@ You are running the script processBETA.sh @"
    echo "@                                           @"
    echo "@ BETA is no longer with us, and it is time @"
    echo "@  to move on.                              @"
    echo "@ Our telescope is ASKAP, and so the script @"
    echo "@  you want is processASKAP.sh              @"
    echo "@ It will now be run with your config file, @"
    echo "@  but please update your workflow!         @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo " "
    
    "${PIPELINEDIR}/processASKAP.sh" "$*"

fi
