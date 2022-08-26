################################################################################
#                             postinstall.sh                                   #
#                                                                              #
# A BASH script to run YUM and install some additional administratively        #
# useful tools, fonts, applications and other stuff. This script is intended   #
# for use with Fedora 16 and above and CentOS 6.0 and above.                   #
#                                                                              #
# This script is installed by the postinstall RPM package. It is intended      #
# to be run after that installation. It could be run stand-alone but some      #
# things may not work.                                                         #
#                                                                              #
#                                                                              #
#                                                                              #
#                               Changelog                                      #
#   Date      Who      Description                                             #
#-----------  -------- --------------------------------------------------------#
# 2009/09/28  dboth    Initial code created from part of the %post section of  #
#                      davidsutils RPM. Performs some configuration and        #
#                      installs some useful RPM packages using YUM that could  #
#                      not be done from within the davidsutils RPM.            #
# 2011/12/31  dboth    Added font cache update to postinstall.sh after         #
#                      installing long list of fonts.                          #
# 2012/01/01  dboth    Extracted the postinstall.sh script from the %post      #
#                      install section of the RPM and added it as a separate   #
#                      file to be installed.                                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Lots of stuff in the intervening years. Major refactoring June 2020.         #
# Mostly removing code not related to Fedora and plenty of cruft. Also         #
# placing more code in-line instead of in unnecessary procedures. Left         #
# the appropriate procedures intact.                                           #
#                                                                              #
#------------------------------------------------------------------------------#
# 2020/06/08  dboth    Refactor large portions of code to simplify and bring   #
#                      certain settings up to date, such as disabling          #
#                      selinux in grun2 on the kernel command line rather      #
#                      than in selinux config file.                            #
# 2020/06/19  dboth    Refactor large portions of code to simplify.            #
#                      Removed more references to and code for CentOS.         #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################

# {
#    # Display Help
#    echo "################################################################################"
#    echo "postinstall.sh: Installs useful administrative tools and programs. "
#    echo
#    echo "This script is installed by the postinstall RPM package. It is "
#    echo "intended for use with Fedora $MinFedoraRelease and above. It has been tested up"
#    echo "through Fedora $CurFedoraRelease."
#    echo "This program installs the RPMFusion free and non-free repositories for Fedora if"
#    echo "they are not already. It also installs all current updates."
#    echo
#    echo "Syntax: ./postinstall.sh -[h]|[V][acCDdfGgiKLlmrSVvxX]|[A]"
#    echo "################################################################################"
#    echo "options:"
#    echo "A     All: Install Applications, LibreOffice, Multimedia, and fonts."
#    echo "           Does not install Development packages or servers."
#    echo "--------------------------------------------------------------------------------------"
#    echo "a     Install various GUI desktop applications including graphics."
#    echo "c     Install various CLI fun apps such as boxes, banner, steam loco, asciiquarium,"
#    echo "          and much more."
#    echo "d     Install development packages such as the kernel devlopment."
#    echo "        -- This will be needed if you are going to install VirtualBox."
#    echo "f     Install more desktop fonts from repository."
#    echo "i     Revert to iptables instead of using firewalld."
#    echo "l     Install LibreOffice."
#    echo "m     Install various multimedia applications for DVD playback and streaming video."
#    echo "r     Reboot after completion."
#    echo "s     Install server software packages."
#    echo "v     Verbose mode."
#    echo "V     Print the version of this software and exit."
#    echo "x     Exit without doing anything. Used to check that the program got the proper"
#    echo "          information about the host an operating system."
#    echo "--------------------------------------------------------------------------------------"
#    echo "###### Options to install Desktops ######"
#    echo "D     Install all desktops listed below."
#    echo "C     Install Cinnamon Desktop."
#    echo "G     Install Gnome Desktop."
#    echo "K     Install KDE Plasma desktop."
#    echo "L     Install LXDE desktop."
#    echo "M     Install MATE desktop."
#    echo "X     Install Xfce desktop."
#    echo "--------------------------------------------------------------------------------------"
#    echo "###### Miscellaneous Options  ######"
#    echo "--------------------------------------------------------------------------------------"
#    echo "y     Automatically answer Yes to all questions that require input of YNQ."
#    echo "h     Print this Help."
#    echo "g     Print the GPL License header."
#    echo "################################################################################"
#    echo "This BASH program is distributed under the GPL V2."
#    echo
#    echo "It is suggested you redirect all output to a log file"
#    echo "to retain a record of what tasks were perfomed. Example below:"
#    echo "./postinstall.sh -[Your chosen options] >> /root/postinstall.log 2>&1"
# }

__Help() {
    echo "Usage: ./Fresh-Install.sh [Options...] <url>"
    echo " -d, --dots           Install various config files."
    echo " -n, --nvim           Install only configs Related to Neovim."
    echo " -g, --grub           Install GRUB Theme."
    echo "Usage: ./Fresh-Install.sh [Options...] <url>"
    echo "Usage: ./Fresh-Install.sh [Options...] <url>"
}

__Help
