libexec_SCRIPTS=check_video_health
GL_MODULES=\
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Extraopts.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Getopt.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/TableItem.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/ALARMMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/HOSTRESOURCESMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/MIB2MIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SNMPFRAMEWORKMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/UCDDISKIOMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/UCDSNMPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/CSF.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/TableItem.pm
EXTRA_MODULES=\
  Classes/MibsAndOids/DELLRACMIB.pm \
  Classes/MibsAndOids/POLYCOMACCESSMANAGEMENTMIB.pm \
  Classes/MibsAndOids/POLYCOMCMAMIB.pm \
  Classes/HOSTRESOURCESMIB/Component/CpuSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/DiskSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/EnvironmentalSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/MemSubsystem.pm \
  Classes/HOSTRESOURCESMIB/Component/UptimeSubsystem.pm \
  Classes/HOSTRESOURCESMIB.pm \
  Classes/UCDMIB/Component/CpuSubsystem.pm \
  Classes/UCDMIB/Component/DiskSubsystem.pm \
  Classes/UCDMIB/Component/LoadSubsystem.pm \
  Classes/UCDMIB/Component/MemSubsystem.pm \
  Classes/UCDMIB/Component/ProcessSubsystem.pm \
  Classes/UCDMIB/Component/SwapSubsystem.pm \
  Classes/UCDMIB.pm \
  Classes/POLYCOMACCESSMANAGEMENTMIB/Component/EnvironmentalSubsystem.pm \
  Classes/POLYCOMACCESSMANAGEMENTMIB.pm \
  Classes/Polycom/WebSuite.pm \
  Classes/Polycom/RPAD.pm \
  Classes/Polycom/CMA/Component/Videosubsystem.pm \
  Classes/Polycom/CMA.pm \
  Classes/Polycom/MCU.pm \
  Classes/Polycom.pm \
  Classes/DELLRACMIB/Component/EnvironmentalSubsystem.pm \
  Classes/DELLRACMIB.pm \
  Classes/ALARMMIB/Component/AlarmSubsystem.pm \
  Classes/ALARMMIB.pm \
  Classes/Device.pm

SED=/bin/sed
GREP=/bin/grep
CAT=/bin/cat
ECHO=/bin/echo
if DISABLE_STANDALONE
STANDALONE = no
else
STANDALONE = yes
endif

SUFFIXES = .pl .pm .sh

VPATH=$(top_srcdir) $(top_srcdir)/plugins-scripts $(top_srcdir)/plugins-scripts/t

EXTRA_DIST=$(libexec_SCRIPTS).pl $(EXTRA_MODULES) $(GL_MODULES)

CLEANFILES=$(libexec_SCRIPTS)

AM_INSTALL_PROGRAM_FLAGS=@INSTALL_OPTS@

.pm :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.pl :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.sh :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

$(libexec_SCRIPTS) : $(EXTRA_DIST)
	$(ECHO) "#! #PERL# -w" | $(AWK) -f ./subst > $@
	$(ECHO) "# nagios: -epn" >> $@
	$(ECHO) >> $@
	if [ "${STANDALONE}" == "yes" ]; then \
		$(ECHO) i am standalone; \
		for m in ${GL_MODULES}; do \
			$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(SED) -e '/^__PACKAGE__/,$$d' | $(AWK) -f ./subst >> $@; \
		done \
	fi
	for m in ${EXTRA_MODULES}; do \
		$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst >> $@; \
	done
	$(ECHO) "package main;" >> $@
	$(CAT) $(libexec_SCRIPTS).pl | $(AWK) -f ./subst >> $@
	chmod +x $@

