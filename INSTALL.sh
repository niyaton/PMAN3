#!/bin/bash
# $Id: INSTALL.sh,v 1.2 2010/02/25 02:54:20 o-mizuno Exp $

TMPE=/tmp/pman_install_error
PERL=/usr/bin/perl

echo "====================================================================="
echo "                       PMAN3 installer script"
echo "====================================================================="
echo "This script automatically generates directories and config.pl script."
echo
############################# Requirements check
echo "Checking sqlite3 ... "
if [ -z "`which sqlite3`" ]; then
    echo "[NG] sqlite3 is not found. Install sqlite3 first."
    exit
else
    echo "[OK] sqlite3 is found."
fi

echo "Checking perl modules ... "
$PERL -e "use DBI;" 2>&1 | head -1 | cut -d ' ' -f 3 > $TMPE
$PERL -e "use DBD::SQLite;" 2>&1 | head -1 | cut -d ' ' -f 3 > $TMPE
$PERL -e "use CGI;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use CGI::Session;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use CGI::Cookie;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use HTML::Template;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use HTML::Scrubber;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use HTML::Entities;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use URI::Escape;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use Encode;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use Digest::MD5;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use MIME::Types;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use XML::Simple;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use XML::RSS;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE
$PERL -e "use Time::HiRes;" 2>&1 | head -1 | cut -d ' ' -f 3 >> $TMPE

if [ -z "`cat $TMPE`" ]; then
    echo "[OK] All necessary perl modules are installed."
    rm -f $TMPE
else
    echo "[NG] Necessary perl modules are not installed."
    cat $TMPE
    rm -f $TMPE
    echo "Install these modules from CPAN."
    exit
fi

############################# Execute Install
echo
echo "Please input user-specific information."
echo
echo "(Step 1) Input title of PMAN script."
echo "=== This is shown in the head of the browser."
read SITE_TITLE
echo
echo "(Step 2) Input PMAN's administrator name."
echo "=== This is shown in the bottom of PMAN screen."
read ADMIN_NAME
echo
echo "(Step 3) Input PMAN's administrator URL."
echo "=== This is shown in the bottom of PMAN screen."
read ADMIN_URL
echo
echo "(Step 4) Input PMAN's administrator password."
echo "=== Password is stored in config.pl by MD5 encryption."
read ADMIN_PASSWD
ADMIN_PASSWD=`echo "use Digest::MD5 qw/md5_hex/; print md5_hex(\"$ADMIN_PASSWD\");" | $PERL`
echo

cat <<EOF | nkf -w > config.pl
#######################################
# ���̤����Ѥ����ѿ� (�桼�������)
#######################################
##
## ���˴ؤ�����
## ================
use utf8;

#  ���Խ��ѥѥ����
#  
#    �Խ��ѥѥ���ɤ��ưפ��������ˤ�����Τ����ꤷ�Ʋ�������
#  
\$PASSWD="$ADMIN_PASSWD";
##
## ɽ���˴ؤ�����
## ================

#  �������ȥ�ʸ����
#
#    ���������Τ��Ϥ륿���ȥ�
#  
\$titleOfSite = "$SITE_TITLE";
#
#  ��������̾
#  �������ԤΥ��ɥ쥹
#
#  �����ȴ����Ԥ�̾���ȥ��ɥ쥹������Ʋ�����
#  �ڡ���������
#  This site is maintained by <a href="$maintainerAddress">$maintainerName</a>.
#  <hr>
#  �Ȥ���ɽ������ޤ���
#
\$maintainerName = "$ADMIN_NAME";
\$maintainerAddress = "$ADMIN_URL";

## LaTeX��ǽ�˴ؤ�����
## =====================
#
# ��LaTeX�⡼�ɤǤ�LaTeX�إå� ����1
#
\$texHeader1 = <<"EOM";
\\\\documentclass{jarticle}
\\\\usepackage{times}
\\\\usepackage{fancyhdr}
\\\\renewcommand{\\\\baselinestretch}{0.85}
\\\\setlength{\\\\topmargin}{-10mm}
\\\\setlength{\\\\oddsidemargin}{0mm}
\\\\setlength{\\\\evensidemargin}{0mm}
\\\\setlength{\\\\textheight}{23.6cm}
\\\\setlength{\\\\textwidth}{16cm}
\\\\title{\\\\LARGE\\\\bf ������ӥꥹ��}

\\\\newcommand{\\\\myName}{}
\\\\newcommand{\\\\myAffiliation}{}
\\\\newcommand{\\\\myTitle}{}
EOM

#\\\\author{ \\\\myAffiliation \\\\\\\\ \\\\myTitle  ~~ \\\\myName }

\$texHeader2 = <<"EOM";
\\\\begin{document}
\\\\maketitle

\\\\pagestyle{fancy}
\\\\thispagestyle{fancy}

\\\\renewcommand{\\\\headrulewidth}{0.5pt}
\\\\renewcommand{\\\\footrulewidth}{0.5pt}
\\\\renewcommand{\\\\sectionmark}[1]{\\\\markright{\\#1}}
\\\\fancyhf{}
\\\\fancyhead[CE,CO]{\\\\bf ������ӥꥹ��}
\\\\fancyhead[RE,LO]{\\\\bf \\\\rightmark}
\\\\fancyfoot[LE,RO]{\\\\thepage}

EOM
#
# �� ���δ֤˥ꥹ�Ȥ���������롥
#
# �� LaTeX�⡼�ɤǤ�LaTeX�եå�
\$texFooter = <<"EOM";
�ʾ塥
\\\\end{document}
EOM

# �桼���ѿ������ ��λ

1;
EOF

echo "Done. Your config.pl is successfully generated."
echo
echo "Making DBs..."
mkdir db
sh ./mkDB.sh
sh ./mkCDB.sh
echo "... DBs are generated"

echo
echo "Making .htaccess files ..."
cat <<EOF > .htaccess
<Files ~ "\.(pl|db|sh)$">
deny from all
</Files>
EOF
cp .htaccess db/ lib/
touch ./index.html ./db/index.html ./lib/index.html 
echo "Done." 
echo
echo "[IMPORTANT]" 
echo "If you used PMAN 2.x,"
echo "UPGRADE.sh will help you to convert your data from old one." 
echo "(But I've tested on PMAN 2.5.6 only...)" 
echo
echo "Install finished. Thank you choosing PMAN3!"
