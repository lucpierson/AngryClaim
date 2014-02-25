#!/bin/sh 
DEMO="AngryClaim Demo"
AUTHORS="Bernard TISON, Luc Pierson"
PROJECT="git@github.com/lucpierson/AngryClaim" 
PRODUCT="JBoss FUSE Service works + BPM Suite BAM"
AG_DEMO_HOME=~/AngryClaim
AG_SRC_DIR=$AG_DEMO_HOME/installs
AG_FSW_HOME=$AG_DEMO_HOME/target_fsw/jboss-eap-6.1
AG_FSW_CONF=$AG_FSW_HOME/standalone/configuration/
AG_BAM_HOME=$AG_DEMO_HOME/target_bpms/jboss-eap-6.1
AG_BAM_CONF=$AG_BAM_HOME/standalone/configuration/
EAP=jboss-eap-6.1.1.zip
BPMS=jboss-bpms-6.0.0.GA-redhat-1-deployable-eap6.x.zip
FSW=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
VERSION=AngryClaim.V1.1

# TWITTER Application CONF
AG_consumerKey="RKSAz48dn9NPNNEfPAntow"
AG_consumerSecret="h3exEYiVO5JVTG15vb1aGcS9t2FGAQiwTVLV0BgE"
AG_accessToken="2325112519-3qxgj7OrCb3aCXex2dxlpSIpRWoXhgZXSWR8uRC"
AG_accessTokenSecret="C3izmkk1Wa2DC2Gwst3nbvOZWozoSgLLfqZYffAKRgHyG"
AG_sinceId=1

# GMAIL SMTP Account configuration
AG_emailserverhost="smtps://smtp.gmail.com:465"
AG_emailserverusername="angryClaim@gmail.com"
AG_emailserverpassword=""

# CSV Directory to Scan
AG_csvInputDir=$AG_DEMO_HOME/etc/csv/demo/



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
echo "# AngryClaim demo variables" >>  ~/.bash_profile
echo 'export AG_consumerKey=' $AG_consumerKey >> ~/.bash_profile
echo 'export AG_consumerSecret=' $AG_consumerSecret >> ~/.bash_profile
echo 'export AG_accessToken=' $AG_accessToken >> ~/.bash_profile
echo 'export AG_accessTokenSecret=' $AG_accessTokenSecret >> ~/.bash_profile
echo 'export AG_sinceId=' $AG_sinceId >> ~/.bash_profile
echo 'export AG_csvInputDir=' $AG_csvInputDir >> ~/.bash_profile
echo 'export AG_emailserverhost=' $AG_emailserverhost >> ~/.bash_profile
echo 'export AG_emailserverusername=' $AG_emailserverusername >> ~/.bash_profile
echo 'export AG_emailserverpassword=' $AG_emailserverpassword >> ~/.bash_profile


echo "verifying MVN installation"
command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }
mv ~/.m2/settings.xml ~/.m2/settings.xml.save
cp $AG_DEMO_HOME/etc/mvn_config/settings.xml ~/.m2/settings.xml



AG_FICHIER=/usr/share/java/mysql-connector-java.jar
test -L "$AG_FICHIER" || test -f "$AG_FICHIER" || { echo "MySQL is required but not installed yet. Please launch yum install mysql* .... aborting."; exit 1; }
service mysqld status ||  { echo "mysql server is not up.... aborting."; exit 1; }

javac -version>/dev/null || { echo "java jdk is required but not installed yet. .... aborting."; exit 1; }

mysql -u root -h localhost -e"CREATE USER 'jboss'@'localhost' IDENTIFIED BY 'jboss';"
mysql -u root -h localhost -e"GRANT ALL PRIVILEGES ON * . * TO 'jboss'@'localhost';"
mysql -u root -h localhost -e"FLUSH PRIVILEGES;"
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
  rm -rf target_fsw
  rm -rf target_bpms
  mkdir target_fsw
  mkdir target_bpms
  echo

# Unzip the JBoss EAP instance.
  echo Unpacking JBoss Enterprise EAP 6...
  echo
  unzip -q -d target_bpms $AG_SRC_DIR/$EAP

# Unzip the required files from JBoss product deployable.
  echo "Unpacking BPMS"
  echo
  unzip -q -o -d target_bpms $AG_SRC_DIR/$BPMS
  cd ~

# install FSW using installation script
  echo "Installing FSW"
#echo "     $AG_SRC_DIR/$FSW :" $AG_SRC_DIR/$FSW
#echo "     $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml : " $AG_SRC_DIR/$FSW $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml
#echo "     $AG_DEMO_HOME/etc/FSW_ServerInstallScript.variables : " $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables

  if [[ -r $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml && -r $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables ]]; then
		echo XML scripts are present...
                cp $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.save --force
                sed -i "s|REPERTOIRE|$AG_DEMO_HOME|" $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml
                # SED : substiture string "REPERTOIRE" with $AG_DEMO_HOME variable
                cd $AG_DEMO_HOME
                java -jar $AG_SRC_DIR/$FSW $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml -variablefile $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables
		echo
  else
		echo "Need to verify that FSW XML installation sript is named as FSW_ServerInstallScript.xml"
		echo "and placed in the " $AG_SRC_DIR/$FSW ll$AG_DEMO_HOME "/etc directory "
		echo "bye for now..."
		exit
  fi
  cd ~


# updating server configurations


echo "  - enabling demo accounts logins in application-users.properties file..."
echo 
  cp $AG_DEMO_HOME/etc/application-users.properties $AG_BAM_CONF  || { echo "application-users.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
  cp $AG_DEMO_HOME/etc/application-roles.properties $AG_BAM_CONF || { echo "application-roles.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling management accounts login setup in mgmt-users.properties file..."
echo
  cp $AG_DEMO_HOME/etc/mgmt-users.properties $AG_BAM_CONF || { echo "mgmt-users.properties not in /.etc.... aborting."; exit 1; }

echo "  - setting up standalone.xml configuration adjustments..."
echo
   cp  $AG_DEMO_HOME/etc/standalone.FSW.xml $AG_FSW_CONF/standalone.xml
   cp  $AG_DEMO_HOME/etc/standalone.BAM.xml $AG_BAM_CONF/standalone.xml

echo "  - turn off security profile for performance in standalone.conf..."
echo
   sed -i 's|JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|#JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|g' $AG_FSW_HOME/bin/standalone.conf
   sed -i 's|JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|#JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|g' $AG_BAM_HOME/bin/standalone.conf

echo "  - additional options  in FSW standalone.conf..."
echo
   echo "# AngryClaim options for Twitter and gmail account" >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DconsumerKey=$AG_consumerKey"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DconsumerSecret=$AG_consumerSecret"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DaccessToken=$AG_accessToken"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DaccessTokenSecret=$AG_accessTokenSecret"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DsinceId=$AG_sinceId"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DcsvInputDir=$AG_csvInputDir"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.host=$AG_emailserverhost"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.username=$AG_emailserverusername"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.password=$AG_emailserverpassword"' >> $AG_FSW_HOME/bin/standalone.conf


echo "  - additional options  in BAM standalone.conf..."
echo
   echo "# AngryClaim options add offset 100 - for demo BAM on business-central" >> $AG_BAM_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Djboss.socket.binding.port-offset=10000"' >>  $AG_BAM_HOME/bin/standalone.conf
   sed -i 's|</dependencies>|<module name="com.mysql" />\n</dependencies>|g ' $AG_BAM_HOME/standalone/deployments/dashbuilder.war/WEB-INF/jboss-deployment-structure.xml


### Camel-twitter configuration
   mkdir -p                                                                           $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
   cp $AG_DEMO_HOME/etc/modules/camel-twitter/module.xml                              $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
   cp $AG_DEMO_HOME/etc/modules/camel-twitter/camel-twitter-2.10.0.redhat-60024-1.jar $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main

####Installation of the twitter4j module
   mkdir -p                                             $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/etc/modules/twitter4j/module.xml    $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/installs/twitter4j-core-3.0.5.jar   $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/installs/twitter4j-stream-3.0.5.jar $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main

# copy CRM MOK file
   cp $AG_DEMO_HOME/etc/crm/crm.properties $AG_FSW_CONF

# create and copy mysql jar dependences files on FSW
   mkdir -p                                       $AG_FSW_HOME/modules/system/layers/base/com/mysql/main
   ln -s /usr/share/java/mysql-connector-java.jar $AG_FSW_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
   cp $AG_DEMO_HOME/etc/mysql/module.xml          $AG_FSW_HOME/modules/system/layers/base/com/mysql/main

# create and copy mysql jar dependences files on BAM
   mkdir -p                                       $AG_BAM_HOME/modules/system/layers/base/com/mysql/main
   ln -s /usr/share/java/mysql-connector-java.jar $AG_BAM_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
   cp $AG_DEMO_HOME/etc/mysql/module.xml          $AG_BAM_HOME/modules/system/layers/base/com/mysql/main
  
# create maven dependency to twitter modules
   mkdir -p                                            ~/.m2/repository/org/apache/camel/camel-twitter/2.10.0.redhat-60024-1
   cp    $AG_DEMO_HOME/etc/modules/camel-twitter/cam*  ~/.m2/repository/org/apache/camel/camel-twitter/2.10.0.redhat-60024-1
   cd    $AG_DEMO_HOME

# update BAM persistency Dialect
sed -i 's|<property name="hibernate.dialect" value="org.hibernate.dialect.H2Dialect" />|<property name="hibernate.dialect" value="org.hibernate.dialect.MySQL5Dialect"/>|g' $AG_BAM_HOME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml

echo "Creating Launchers  : /FSW_Launch.sh and /BAM_Launch.sh"

echo "#Launch Fuse Service works for Demo AngryClaim" >> $AG_DEMO_HOME/FSW_Launch.sh
cat ./etc/setSinceId.txt >> $AG_DEMO_HOME/FSW_Launch.sh
echo "# AngryClaim demo variables" >>  $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_consumerKey=' $AG_consumerKey >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_consumerSecret=' $AG_consumerSecret >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_accessToken=' $AG_accessToken >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_accessTokenSecret=' $AG_accessTokenSecret >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_sinceId=' $AG_sinceId >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_csvInputDir=' $AG_csvInputDir >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverhost=' $AG_emailserverhost >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverusername=' $AG_emailserverusername >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverpassword=' $AG_emailserverpassword >> $AG_DEMO_HOME/FSW_Launch.sh
echo $AG_FSW_HOME/bin/standalone.sh >> $AG_DEMO_HOME/FSW_Launch.sh

echo "#Launch BPM-Suite BAM for Demo AngryClaim"  >> $AG_DEMO_HOME/BAM_Launch.sh
echo $AG_BAM_HOME/bin/standalone.sh >> $AG_DEMO_HOME/BAM_Launch.sh

chmod +x BAM_Launch.sh FSW_Launch.sh


echo
echo "Other actions may be very long, please launch them Manually : "
echo "  1) creation of the deployable applications with maven clean package"
echo "        mvn clean package  "
echo "  2) Deploy the application into Fuse Service works"
echo "        cp " $AG_DEMO_HOME/crm-service/target/crm-service.war " " $AG_FSW_HOME/standalone/deployments/
echo "        cp " $AG_DEMO_HOME/switchyard-ear/target/switchyard-angrytweet.ear " " $AG_FSW_HOME/standalone/deployments/
echo " "     
echo " "
echo "Before FSW re-start, update of the CRM users  in" 
echo "            "  $AG_FSW_HOME "/standalone/configuration/crm.properties"
echo " "
echo "After BAM Start, in the dashboard configuration, create"
echo "    create datatsource as  JNDI , name=AngryClamDB  jndi=java:jboss/datasources/AngryTweetDS" 
echo "    and import the following file into the BAM Workbench"
echo "            "  $AG_DEMO_HOME "/etc/BAM/kpiExport_76041004.xml"
echo "            "  $AG_DEMO_HOME "/etc/BAM/export_workspace.cex"
echo " "
echo "You can now start FSW  with FSW_Launch.sh "
echo " "
echo "               and BAM with BAM_Launch.sh "
echo " "
echo "URL to launch BAM is "
echo "            http://localhost:18080/dashbuilder/workspace/en/AngryClaimShowcase" 
echo 
echo
echo "BAM users  are : "
echo "#    admin / redhat123@"
echo "#    btic  / redhat123@"
echo




# luc / luc9999ç
# add in BAM/standalone/configuration/application-user : luc=212420d26951218a06cf95ab5f7cd8ca 

# create dataProvider : actionsFromSource
#         select * from ticket order by channel_in
# create dataProvider : cbyc_sup1
#    select customer, area_code,compteur from(  select customer, area_code, count(*) as compteur  from (select customer,area_code, urgent  from ( select customer, channel_in, area_code, urgent from  angrytweet.ticket group by customer,channel_in order by customer, channel_in) AS T) as T2  group by customer) as T3 where compteur>1;
echo
echo
echo
echo
echo "Setup Complete. Have Fun  with Fuse Service Works"
echo " the Authors :  ${AUTHORS}"
echo




