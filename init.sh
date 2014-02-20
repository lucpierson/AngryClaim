#!/bin/sh 
DEMO="AngryClaim Demo"
AUTHORS="Bernard TISON, Luc Pierson"
PROJECT="git@github.com/lucpierson/AngryClaim" 
PRODUCT="JBoss FUSE Service works + BPM Suite BAM"
AG_DEMO_HOME=~/AngryClaim
AG_SRC_DIR=$AG_DEMO_HOME/installs
AG_FSW_HOME=$AG_DEMO_HOME/target_fws/jboss-eap-6.1
AG_FSW_CONF=$AG_FSW_HOME/standalone/configuration/
AG_BAM_HOME=$AG_DEMO_HOME/target_bpms/jboss-eap-6.1
AG_BAM_CONF=$AG_BAM_HOME/standalone/configuration/
EAP=jboss-eap-6.1.1.zip
BPMS=jboss-bpms-6.0.0.GA-redhat-1-deployable-eap6.x.zip
FSW=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
VERSION=AngryClaim.V1.1

# wipe screen.
clear 

echo
echo "#################################################################"
echo "##                                                             ##"   
echo "##  Setting up the ${DEMO} "
echo "##                                                             ##"   
echo "##                                                             ##"   
echo "##  brought to you by,                                         ##"   
echo "##   ${AUTHORS} "
echo "##                                                             ##"   
echo "##  ${PROJECT} "
echo "##                                                             ##"   
echo "#################################################################"
echo

echo "creating system variables"
echo
sed -i  'i/# AngryClaim demo variables' ~/.bash_profile
sed -i  'i/export AG_consumerKey="RKSAz48dn9NPNNEfPAntow"' ~/.bash_profile
sed -i  'i/AG_consumerSecret="h3exEYiVO5JVTG15vb1aGcS9t2FGAQiwTVLV0BgE"' ~/.bash_profile
sed -i  'i/AG_accessToken="2325112519-3qxgj7OrCb3aCXex2dxlpSIpRWoXhgZXSWR8uRC"' ~/.bash_profile
sed -i  'i/AG_accessTokenSecret="C3izmkk1Wa2DC2Gwst3nbvOZWozoSgLLfqZYffAKRgHyG"' ~/.bash_profile
sed -i  'i/AG_sinceId=1' ~/.bash_profile
sed -i  'i/AG_csvInputDir=$AG_DEMO_HOME/etc/csv/demo/' ~/.bash_profile
sed -i  'i/AG_emailserverhost="smtps://smtp.gmail.com:465"' ~/.bash_profile
sed -i  'i/AG_emailserverusername="angryClaim@gmail.com"' ~/.bash_profile
sed -i  'i/AG_emailserverpassword=""' ~/.bash_profile


command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

AG_FICHIER=/usr/share/java/mysql-connector-java.jar
test -L "$AG_FICHIER" || test -f "$AG_FICHIER" || { echo "MySQL is required but not installed yet. Please launch yum install mysql* .... aborting."; exit 1; }
service mysqld status ||  { echo "mysql server is not up.... aborting."; exit 1; }

javac -version>/dev/null || { echo "java jdk is required but not installed yet. .... aborting."; exit 1; }

mysql -u root -p -h localhost -e"CREATE USER 'jboss'@'localhost' IDENTIFIED BY 'jboss';"
mysql -u root -p -h localhost -e"GRANT ALL PRIVILEGES ON * . * TO 'jboss'@'localhost';"
mysql -u root -p -h localhost -e"FLUSH PRIVILEGES;"
mysql -u jboss -pjboss -h localhost -e"create schema angrytweet;"
mysql -u jboss -pjboss -h localhost -e"create schema bpmsdemo;" || { echo "Error in creating required databases. Please check and try again....."; exit 1; }

# make some checks first before proceeding.	
if [[ -r $AG_SRC_DIR/$EAP || -L $AG_SRC_DIR/$EAP ]]; then
		echo EAP sources are present...
		echo
else
		echo Need to download $EAP package from the Customer Portal 
		echo and place it in the $AG_SRC_DIR directory to proceed...
		echo
		exit
fi

# Create the target directory if it does not already exist.
  echo "  - creating the target directory..."
  echo
  rm -rf target_fws
  rm -rf target_bpms
  mkdir target_fws
  mkdir target_bpms
  echo

# Unzip the JBoss EAP instance.
echo Unpacking new JBoss Enterprise EAP 6...
echo
unzip -q -d target_bpms $AG_SRC_DIR/$EAP

# Unzip the required files from JBoss product deployable.
echo Unpacking $PRODUCT $VERSION...
echo
unzip -q -o -d target_bpms $AG_SRC_DIR/$BPMS

# install FSW using installation script
echo Installing FSW
echo
java -jar $AG_SRC_DIR/$FSW $AG_DEMO/etc/FSW_ServerInstallScript.xml -variablefile $AG_DEMO/etc/FSW_ServerInstallScript.variables

cd ~


echo "  - enabling demo accounts logins in application-users.properties file..."
echo 
cp $AG_DEMO/etc/application-users.properties $AG_BAM_CONF  || { echo "application-users.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $AG_DEMO/etc/application-roles.properties $AG_BAM_CONF || { echo "application-roles.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling management accounts login setup in mgmt-users.properties file..."
echo
cp $AG_DEMO/etc/mgmt-users.properties $AG_BAM_CONF || { echo "mgmt-users.properties not in /.etc.... aborting."; exit 1; }


echo "----------------------"



echo "  - setting up standalone.xml configuration adjustments..."
echo
cp  $AG_DEMO/etc/standalone.FSW.xml $AG_FSW_CONF/standalone.xml
cp  $AG_DEMO/etc/standalone.BAM.xml $AG_BAM_CONF/standalone.xml





echo "  - turn off security profile for performance in standalone.conf..."
echo
sed -i '' 's/JAVA_OPTS="$JAVA_OPTS -Djava.security.manager/#JAVA_OPTS="$JAVA_OPTS -Djava.security.manager/g' $AG_FSW_HOME/bin/standalone.conf
sed -i '' 's/JAVA_OPTS="$JAVA_OPTS -Djava.security.manager/#JAVA_OPTS="$JAVA_OPTS -Djava.security.manager/g' $AG_BAM_HOME/bin/standalone.conf

echo "----------------------"

echo "  - additional options  in FSW standalone.conf..."
echo
sed -i  'i/# AngryClaim options for Twitter and gmail account' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DconsumerKey=$AG_consumerKey"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DconsumerSecret=$AG_consumerSecret"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DaccessToken=$AG_accessToken"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DaccessTokenSecret=$AG_accessTokenSecret"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DsinceId=$AG_sinceId"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -DcsvInputDir=$AG_csvInputDir"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -Demail.server.host=$AG_emailserverhost"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -Demail.server.username=$AG_emailserverusername"' $AG_FSW_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -Demail.server.password=$AG_emailserverpassword"' $AG_FSW_HOME/bin/standalone.conf


echo "  - additional options  in BAM standalone.conf..."
echo
sed -i  'i/# AngryClaim options add offset 100 - for demo BAM on business-central' $AG_BAM_HOME/bin/standalone.conf
sed -i  'i/JAVA_OPTS="$JAVA_OPTS -Djboss.socket.binding.port-offset=10000"' $AG_BAM_HOME/bin/standalone.conf


### Camel-twitter configuration
mkdir $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter
mkdir $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
cp $AG_DEMO/etc/modules/camel-twitter/module.xml $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
cp $AG_DEMO/etc/modules/camel-twitter/camel-twitter-2.10.0.redhat-60024-1.jar $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main

####Installation of the twitter4j module
mkdir $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j
mkdir $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
cp $AG_DEMO/etc/modules/twitter4j/module.xml $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
cp $AG_DEMO/installs/twitter4j-core-3.0.5.jar $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
cp $AG_DEMO/installs/twitter4j-stream-3.0.5.jar $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main

# copy CRM MOK file
cp $AG_DEMO/etc/crm/crm.properties $AG_FSW_HOME/standalone/configuration/

# create and copy mysql jar dependences files on FSW
mkdir $AG_FSW_HOME/modules/system/layers/base/com/mysql
mkdir $AG_FSW_HOME/modules/system/layers/base/com/mysql/main
ln -s /usr/share/java/mysql-connector-java.jar $AG_FSW_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
cp $AG_DEMO/etc/mysql/module.xml $AG_FSW_HOME/modules/system/layers/base/com/mysql/main

# create and copy mysql jar dependences files on BAM
mkdir $AG_BAM_HOME/modules/system/layers/base/com/mysql
mkdir $AG_BAM_HOME/modules/system/layers/base/com/mysql/main
ln -s /usr/share/java/mysql-connector-java.jar $AG_BAM_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
cp $AG_DEMO/etc/mysql/module.xml $AG_BAM_HOME/modules/system/layers/base/com/mysql/main



# deployments FSW apps
deploy  web-service : 
    cp $AG_DEMO/crm-service/target/crm-service.war $AG_FSW_HOME/standalone/deployments/
deploy le swityard
    cp $AG_DEMO/switchyard-ear/target/switchyard-angrytweet.ear $AG_FSW_HOME/standalone/deployments/


echo "Before FSW start, update of the CRM users should be done in" 
echo "            "  $AG_FSW_HOME/standalone/configuration/crm.properties
echo " "
echo "After BAM Start, import the following file into the BAM Workbench"
echo "            "  $AG_DEMO/etc/kpiExport_76041004.xml
echo " "
echo "You can now start FSW  with $AG_FSW_HOME/bin/standalone.sh "
echo "               and BAM with $AG_BAM_HOME/bin/standalone.sh "
echo " "
echo "URL to lauch BAM is "
echo "            http://localhost:18080/dashbuilder/workspace/en/AngryClaimShowcase" 


# echo BAM users : 
#    admin / redhat123@
#    btic  / redhat123@


echo "$PRODUCT $VERSION $DEMO Setup Complete. Have Fun  with Fuse Service Works"
echo




