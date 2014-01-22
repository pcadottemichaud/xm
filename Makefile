STARTING_DIR=$(CURDIR)

# XiVO paths
ASTERISK_PATH=$(XIVO_PATH)/asterisk11
AGENT_PATH=$(XIVO_PATH)/xivo-agent
AGI_PATH=$(XIVO_PATH)/xivo-agid
BUS_PATH=$(XIVO_PATH)/xivo-bus
CALL_LOGS_PATH=$(XIVO_PATH)/xivo-call-logs
CONFGEN_PATH=$(XIVO_PATH)/xivo-confgen
CTI_PATH=$(XIVO_PATH)/xivo-ctid
DAO_PATH=$(XIVO_PATH)/xivo-dao
DIRD_PATH=$(XIVO_PATH)/xivo-dird
DOC_PATH=$(XIVO_PATH)/xivo-doc
FETCHFW_PATH=$(XIVO_PATH)/xivo-fetchfw
LIB_PYTHON_PATH=$(XIVO_PATH)/xivo-lib-python
RESTAPI_PATH=$(XIVO_PATH)/xivo-restapi
SCCP_PATH=$(XIVO_PATH)/xivo-libsccp
SYSCONF_PATH=$(XIVO_PATH)/xivo-sysconfd
WEBI_PATH=$(XIVO_PATH)/xivo-web-interface

# PYTHONPATHS
LIB_PYTHON_PP=$(LIB_PYTHON_PATH)/xivo-lib-python
BUS_PP=$(BUS_PATH)/xivo-bus
XIVO_DAO_PYTHONPATH=$(XIVO_PATH)/xivo-dao/xivo-dao
XIVO_DIRD_PYTHONPATH=$(XIVO_PATH)/xivo-dird/xivo-dird
XIVO_AGENT_PYTHONPATH=$(XIVO_PATH)/xivo-agent/xivo-agent
XIVO_PROVD_PYTHONPATH=$(XIVO_PATH)/xivo-provisioning/xivo-provisioning/src
CTI_PP=$(CTI_PATH)/xivo-ctid

XIVO_PYTHONPATH=$(LIB_PYTHON_PP):$(XIVO_DAO_PYTHONPATH):$(XIVO_DIRD_PYTHONPATH):$(XIVO_AGENT_PYTHONPATH):$(XIVO_PROVD_PYTHONPATH):$(CTI_PP):$(BUS_PP)

# Local paths
AGENT_LOCAL_PATH=$(AGENT_PATH)/xivo-agent/xivo_agent
AGI_LOCAL_PATH=$(AGI_PATH)/xivo-agid/xivo_agid
ASTERISK_LOCAL_PATH=$(shell /usr/bin/dirname $(shell /usr/bin/find $(ASTERISK_PATH) -name 'BUGS'))
BUS_LOCAL_PATH=$(BUS_PATH)/xivo-bus/xivo_bus
CALL_LOGS_LOCAL_PATH=$(CALL_LOGS_PATH)/xivo-call-logs/xivo_call_logs
CONFGEN_LOCAL_PATH=$(CONFGEN_PATH)/xivo-confgen/xivo_confgen
CTI_LOCAL_PATH=$(CTI_PATH)/xivo-ctid/xivo_cti
DAO_LOCAL_PATH=$(DAO_PATH)/xivo-dao/xivo_dao
DIRD_LOCAL_PATH=$(DIRD_PATH)/xivo-dird/xivo_dird
FETCHFW_LOCAL_PATH=$(FETCHFW_PATH)/xivo-fetchfw/xivo_fetchfw
LIB_PYTHON_LOCAL_PATH=$(LIB_PYTHON_PATH)/xivo-lib-python/xivo
XIVO_DAO_LOCAL_PATH=$(XIVO_DAO_PYTHONPATH)/xivo_dao
SCCP_LOCAL_PATH=$(XIVO_PATH)/xivo-libsccp
SYSCONF_LOCAL_PATH=$(SYSCONF_PATH)/xivo-sysconfd/xivo_sysconf
UPGRADE_LOCAL_PATH=$(XIVO_PATH)/xivo-upgrade/xivo-upgrade
RESTAPI_LOCAL_PATH=$(RESTAPI_PATH)/xivo-restapi/xivo_restapi
FETCHFW_DATA_LOCAL=$(FETCHFW_PATH)/xivo-fetchfw/resources/data/
WEBI_LOCAL_PATH=$(WEBI_PATH)/xivo-web-interface/src

# Remote paths
PYTHON_PACKAGES=/usr/lib/pymodules/python2.7
WEBI_REMOTE_PATH=/usr/share/xivo-web-interface
FETCHFW_DATA_PATH=/var/lib/xivo-fetchfw/installable

# Tags
AGI_TAGS=$(AGI_PATH)/TAGS
CTI_TAGS=$(CTI_PATH)/TAGS
DAO_TAGS=$(DAO_PATH)/TAGS
SCCP_TAGS=$(SCCP_PATH)/TAGS
WEBI_TAGS=$(WEBI_PATH)/TAGS

SCCP_CSCOPE_FILES=$(SCCP_PATH)/cscope.files

# Commands
SYNC=rsync -vrtlp --filter '- *.pyc' --filter '- *.git' --filter '- *~'
XIVO_LIBSCCP_BUILDH=./build-tools/buildh
XIVO_LIBSCCP_DEP_COMMAND='apt-get update && apt-get install build-essential autoconf automake libtool asterisk-dev'

# xivo-web-interface
.PHONY : webi.sync webi.ctags
webi.ctags:
	rm -f $(WEBI_TAGS)
	ctags -o $(WEBI_TAGS) -R -e --langmap=php:.php.inc $(WEBI_LOCAL_PATH)

webi.sync:
	$(SYNC) $(WEBI_LOCAL_PATH)/ $(XIVO_HOSTNAME):$(WEBI_REMOTE_PATH)

# xivo-fetchfw
.PHONY : fetchfw.sync
fetchfw.sync:
	$(SYNC) $(FETCHFW_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	$(SYNC) $(FETCHFW_DATA_LOCAL) $(XIVO_HOSTNAME):$(FETCHFW_DATA_PATH)

# xivo-agent
.PHONY : agent.sync agent.unittest
agent.sync:
	$(SYNC) $(AGENT_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-agent restart'

agent.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(AGENT_LOCAL_PATH)
endif

# xivo-agid
.PHONY : agi.sync agi.unittest agi.ctags
agi.sync:
	$(SYNC) $(AGI_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-agid restart'

agi.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(AGI_LOCAL_PATH)
endif

agi.ctags:
	rm -f $(AGI_TAGS)
	ctags -o $(AGI_TAGS) -R -e $(AGI_LOCAL_PATH)

# xivo-bus
.PHONY : bus.sync bus.unittest
bus.sync:
	$(SYNC) $(BUS_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

bus.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(BUS_LOCAL_PATH)
endif

# xivo-call-logs
.PHONE : call-logs.sync
call-logs.sync:
	$(SYNC) $(CALL_LOGS_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-confgen
.PHONY : confgen.sync
confgen.sync:
	$(SYNC) $(CONFGEN_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-confgend restart'


# xivo-ctid
.PHONY : cti.unittest
cti.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(CTI_LOCAL_PATH)
endif

.PHONY : cti.sync
cti.sync:
	$(SYNC) $(CTI_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-ctid restart'

.PHONY : cti.ctags
cti.ctags:
	rm -f $(CTI_TAGS)
	ctags -o $(CTI_TAGS) -R -e $(CTI_LOCAL_PATH)
	ctags -o $(CTI_TAGS) -R -e -a $(XIVO_DAO_LOCAL_PATH)
	ctags -o $(CTI_TAGS) -R -e -a $(LIB_PYTHON_LOCAL_PATH)

# xivo-dao
.PHONY : dao.sync dao.unittest dao.ctags
dao.sync:
	$(SYNC) $(DAO_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

.PHONY : dao.unittest
dao.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(DAO_LOCAL_PATH)
endif

dao.ctags:
	rm -f $(DAO_TAGS)
	ctags -o $(DAO_TAGS) -R -e $(DAO_LOCAL_PATH)

# xivo-dird
.PHONY : dird.sync
dird.sync:
	$(SYNC) $(DIRD_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-doc
.PHONY : doc.build
doc.build:
	cd $(DOC_PATH) && make html

.PHONY : doc.clean
doc.clean:
	cd $(DOC_PATH) && make clean

.PHONY : doc.rebuild
doc.rebuild: doc.clean doc.build

# xivo-lib-python
.PHONY : lib-python.sync
lib-python.sync:
	$(SYNC) $(LIB_PYTHON_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-libsccp
.PHONY : sccp.sync
sccp.sync:
	cd $(SCCP_LOCAL_PATH)/xivo-libsccp && $(XIVO_LIBSCCP_BUILDH) makei

.PHONY : sccp.dep
sccp.dep:
	ssh $(XIVO_HOSTNAME) $(XIVO_LIBSCCP_DEP_COMMAND)

.PHONY : sccp.setup
sccp.setup:
	cd $(SCCP_LOCAL_PATH)/xivo-libsccp && $(XIVO_LIBSCCP_BUILDH) init

.PHONY : sccp.ctags
sccp.ctags:
	rm -f $(SCCP_TAGS)
	ctags -o $(SCCP_TAGS) -R -e $(SCCP_LOCAL_PATH)
	ctags -o $(SCCP_TAGS) -R -e -a $(ASTERISK_LOCAL_PATH)

.PHONY : sccp.cscope
sccp.cscope:
	rm -f $(SCCP_CSCOPE_FILES)
	find $(SCCP_LOCAL_PATH) -name "*.c" -o -name "*.h" > $(SCCP_CSCOPE_FILES)
	find $(ASTERISK_LOCAL_PATH) -name "*.c" -o -name "*.h" >> $(SCCP_CSCOPE_FILES)

# xivo-provd
.PHONY : provd.sync
provd.sync:
	$(SYNC) $(XIVO_PROVD_PYTHONPATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-upgrade
.PHONY : upgrade.sync

upgrade.sync:
	$(SYNC) $(UPGRADE_LOCAL_PATH)/bin/ $(XIVO_HOSTNAME):/usr/bin/

# xivo-restapi
.PHONY : restapi.unittest restapi.sync restapi.functest

restapi.sync:
	$(SYNC) $(RESTAPI_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

restapi.unittest:
ifdef TARGET_FILE
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(TARGET_FILE)
else
	PYTHONPATH=$(XIVO_PYTHONPATH) nosetests $(RESTAPI_LOCAL_PATH)
endif

restapi.functest:
	PYTHONPATH=$(XIVO_PYTHONPATH):$(XIVO_PATH)/xivo-acceptance:$(XIVO_PATH)/xivo-ws lettuce -v3 ~/d/xivo-restapi/xivo-restapi/acceptance


# xivo-sysconf
.PHONY : sysconf.sync
sysconf.sync:
	$(SYNC) $(SYSCONF_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# asterisk
.PHONY : asterisk.clean asterisk.generate asterisk.refresh

asterisk.clean:
	rm -fr $(ASTERISK_PATH)/asterisk/tmp/

asterisk.generate:
	$(ASTERISK_PATH)/asterisk/prepare_test_sources.sh

asterisk.refresh: asterisk.clean asterisk.generate sccp.ctags sccp.cscope
