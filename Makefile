XM_PATH=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# XiVO paths
ASTERISK_PATH=$(XIVO_PATH)/asterisk11
AGENT_PATH=$(XIVO_PATH)/xivo-agentd
AGI_PATH=$(XIVO_PATH)/xivo-agid
BACKUP_PATH=$(XIVO_PATH)/xivo-backup
BUS_PATH=$(XIVO_PATH)/xivo-bus
CALL_LOGS_PATH=$(XIVO_PATH)/xivo-call-logs
CONFGEN_PATH=$(XIVO_PATH)/xivo-confgend
CONFD_CLIENT_PATH=$(XIVO_PATH)/xivo-confd-client
CONFIG_PATH=$(XIVO_PATH)/xivo-config
CONSUL_PATH=$(XIVO_PATH)/xivo-consul-packaging
CTI_PATH=$(XIVO_PATH)/xivo-ctid
CTIDNG_PATH=$(XIVO_PATH)/xivo-ctid-ng
DAO_PATH=$(XIVO_PATH)/xivo-dao
DIRD_PATH=$(XIVO_PATH)/xivo-dird
DIRD_CLIENT_PATH=$(XIVO_PATH)/xivo-dird-client
DOC_PATH=$(XIVO_PATH)/xivo-doc
FETCHFW_PATH=$(XIVO_PATH)/xivo-fetchfw
LIB_PYTHON_PATH=$(XIVO_PATH)/xivo-lib-python
CONFD_PATH=$(XIVO_PATH)/xivo-confd
SCCP_PATH=$(XIVO_PATH)/xivo-libsccp
SYSCONF_PATH=$(XIVO_PATH)/xivo-sysconfd
WEBI_PATH=$(XIVO_PATH)/xivo-web-interface
LIB_REST_CLIENT_PATH=$(XIVO_PATH)/xivo-lib-rest-client

# PYTHONPATHS
LIB_PYTHON_PP=$(LIB_PYTHON_PATH)
BUS_PP=$(BUS_PATH)
XIVO_DAO_PYTHONPATH=$(XIVO_PATH)/xivo-dao
XIVO_DIRD_PYTHONPATH=$(XIVO_PATH)/xivo-dird
XIVO_AGENT_PYTHONPATH=$(XIVO_PATH)/xivo-agent
XIVO_PROVD_PYTHONPATH=$(XIVO_PATH)/xivo-provisioning
CTI_PP=$(CTI_PATH)

XIVO_PYTHONPATH=$(LIB_PYTHON_PP):$(XIVO_DAO_PYTHONPATH):$(XIVO_DIRD_PYTHONPATH):$(XIVO_AGENT_PYTHONPATH):$(XIVO_PROVD_PYTHONPATH):$(CTI_PP):$(BUS_PP)
TMP_PYTHONPATH=/root/build/lib/python2.7/site-packages
REMOTE_PYTHONPATH=/usr/lib/python2.7/dist-packages

# Local paths
AGENT_LOCAL_PATH=$(AGENT_PATH)/xivo_agent
AGI_LOCAL_PATH=$(AGI_PATH)/xivo_agid
ALEMBIC_LOCAL_PATH=$(XIVO_PATH)/xivo-manage-db/alembic/versions
AMID_LOCAL_PATH=$(XIVO_PATH)/xivo-amid/xivo_ami
AUTH_LOCAL_PATH=$(XIVO_PATH)/xivo-auth/xivo_auth
ASTERISK_LOCAL_PATH=$(shell /usr/bin/dirname $(shell /usr/bin/find $(ASTERISK_PATH) -name 'BUGS'))
BUS_LOCAL_PATH=$(BUS_PATH)/xivo_bus
CALL_LOGS_LOCAL_PATH=$(CALL_LOGS_PATH)/xivo_call_logs
CONFGEN_LOCAL_PATH=$(CONFGEN_PATH)/xivo_confgen
CTI_LOCAL_PATH=$(CTI_PATH)/xivo_cti
CONFD_CLIENT_LOCAL_PATH=$(CONFD_CLIENT_PATH)/xivo_confd_client
DAO_LOCAL_PATH=$(DAO_PATH)/xivo_dao
DIALPLAN_LOCAL_PATH=$(CONFIG_PATH)/dialplan/asterisk
DIRD_LOCAL_PATH=$(DIRD_PATH)/xivo_dird
DIRD_CLIENT_LOCAL_PATH=$(DIRD_CLIENT_PATH)/xivo_dird_client
FETCHFW_LOCAL_PATH=$(FETCHFW_PATH)/xivo_fetchfw
LIB_PYTHON_LOCAL_PATH=$(LIB_PYTHON_PATH)/xivo
XIVO_DAO_LOCAL_PATH=$(XIVO_DAO_PYTHONPATH)/xivo_dao
SCCP_LOCAL_PATH=$(XIVO_PATH)/xivo-libsccp
STAT_LOCAL_PATH=$(XIVO_PATH)/xivo-stat
SYSCONF_LOCAL_PATH=$(SYSCONF_PATH)/xivo_sysconf
UPGRADE_LOCAL_PATH=$(XIVO_PATH)/xivo-upgrade
CONFD_LOCAL_PATH=$(CONFD_PATH)/xivo_confd
FETCHFW_DATA_LOCAL=$(FETCHFW_PATH)/xivo-fetchfw/resources/data/
WEBI_LOCAL_PATH=$(WEBI_PATH)/src
LIB_REST_CLIENT_LOCAL_PATH=$(LIB_REST_CLIENT_PATH)/xivo_lib_rest_client

# Remote paths
ALEMBIC_REMOTE_PATH=/usr/share/xivo-manage-db/alembic/versions
PYTHON_PACKAGES=/usr/lib/python2.7/dist-packages/
WEBI_REMOTE_PATH=/usr/share/xivo-web-interface
FETCHFW_DATA_PATH=/var/lib/xivo-fetchfw/installable
DIALPLAN_REMOTE_PATH=/usr/share/xivo-config/dialplan/asterisk

# Tags
AGI_TAGS=$(AGI_PATH)/TAGS
ASTERISK_TAGS=$(ASTERISK_PATH)/TAGS
BUS_TAGS=$(BUS_PATH)/TAGS
CONFD_TAGS=$(CONFD_PATH)/TAGS
CTI_TAGS=$(CTI_PATH)/TAGS
DAO_TAGS=$(DAO_PATH)/TAGS
DIRD_TAGS=$(DIRD_PATH)/TAGS
SCCP_TAGS=$(SCCP_PATH)/TAGS
WEBI_TAGS=$(WEBI_PATH)/TAGS

ASTERISK_CSCOPE_FILES=$(ASTERISK_PATH)/cscope.files
SCCP_CSCOPE_FILES=$(SCCP_PATH)/cscope.files

# Commands
SYNC=rsync -vrtlp --filter '- *.pyc' --filter '- *.git' --filter '- *~'
XIVO_LIBSCCP_BUILDH=./buildh
XIVO_LIBSCCP_DEP_COMMAND='apt-get update && apt-get install build-essential autoconf automake libtool asterisk-dev'

# shared targets
.PHONY : sync.bootstrap xivo.umount
sync.bootstrap:
	ssh -q $(XIVO_HOSTNAME) "mkdir -p ~/dev ${TMP_PYTHONPATH}"
	$(SYNC) $(XM_PATH)/bin/00-pre-upgrade.sh $(XIVO_HOSTNAME):"/usr/share/xivo-upgrade/post-stop.d/"

xivo.umount: dird.umount cti.umount dialplan.umount ctid-ng.umount confd.umount ;

# xivo-auth
.PHONY : auth.sync
auth.sync:
	$(SYNC) --delete $(XIVO_PATH)/xivo-auth $(XIVO_HOSTNAME):/tmp
	$(SYNC) $(XIVO_PATH)/xivo-auth/bin/xivo-auth $(XIVO_HOSTNAME):/usr/bin/
	$(SYNC) $(XIVO_PATH)/xivo-auth/etc/xivo-auth/ $(XIVO_HOSTNAME):/etc/xivo-auth
	ssh $(XIVO_HOSTNAME) 'cd /tmp/xivo-auth && python setup.py develop'

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
.PHONY : agent.sync agentd-client.sync agentd-cli.sync
agent.sync:
	$(SYNC) $(AGENT_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-agentd restart'

agentd-client.sync:
	$(SYNC) --delete $(XIVO_PATH)/xivo-agentd-client $(XIVO_HOSTNAME):/tmp
	ssh $(XIVO_HOSTNAME) 'cd /tmp/xivo-agentd-client && python setup.py develop'

agentd-cli.sync:
	$(SYNC) $(XIVO_PATH)/xivo-agentd-cli/xivo_agentd_cli $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-agid
.PHONY : agi.sync agi.ctags
agi.sync:
	$(SYNC) $(AGI_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-agid restart'

agi.ctags:
	rm -f $(AGI_TAGS)
	ctags -o $(AGI_TAGS) -R -e $(AGI_LOCAL_PATH)

# xivo-amid
.PHONY : amid.sync
amid.sync:
	$(SYNC) $(AMID_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-backup
.PHONE : backup.sync
backup.sync:
	$(SYNC) $(BACKUP_PATH)/bin/ $(XIVO_HOSTNAME):/usr/sbin

################################################################################
# xivo-bus
################################################################################

.PHONY : bus.sync bus.clean bus.tags
bus.sync:
	$(SYNC) $(BUS_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

bus.tags: bus.clean
	ctags -o $(BUS_TAGS) -R -e $(BUS_LOCAL_PATH)

bus.clean:
	rm -rf $(BUS_PATH)/.tox
	find $(BUS_PATH) -name '*.pyc' -delete
	rm -f $(BUS_TAGS)

################################################################################
# xivo-call-logs
################################################################################

.PHONY : call-logs.sync
call-logs.sync:
	$(SYNC) $(CALL_LOGS_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-confgen
.PHONY : confgen.sync
confgen.sync:
	$(SYNC) $(CONFGEN_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)
	ssh $(XIVO_HOSTNAME) '/etc/init.d/xivo-confgend restart'

################################################################################
# xivo-ctid
################################################################################

.PHONY : cti.sync cti.ctags cti.clean cti.umount cti.restart
cti.sync: sync.bootstrap cti.umount
	rsync -av --delete --exclude "*.git" --exclude "*.tox" $(CTI_PATH)/ $(XIVO_HOSTNAME):~/dev/xivo-ctid
	ssh -q $(XIVO_HOSTNAME) "cd ~/dev/xivo-ctid && PYTHONPATH=${TMP_PYTHONPATH} python setup.py install --prefix=~/build"
	ssh -q $(XIVO_HOSTNAME) "mount --bind ~/dev/xivo-ctid/build/lib.linux-*-2.7/xivo_cti ${REMOTE_PYTHONPATH}/xivo_cti"
	ssh -q $(XIVO_HOSTNAME) "mount --bind ~/dev/xivo-ctid/xivo_ctid.egg-info ${REMOTE_PYTHONPATH}/xivo_ctid-$(shell $(CTI_PATH)/setup.py --version).egg-info"

cti.umount:
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_cti || true'
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_ctid-*.egg-info || true'

cti.ctags: cti.clean
	ctags -o $(CTI_TAGS) -R -e $(CTI_LOCAL_PATH)
	ctags -o $(CTI_TAGS) -R -e -a $(XIVO_DAO_LOCAL_PATH)
	ctags -o $(CTI_TAGS) -R -e -a $(LIB_PYTHON_LOCAL_PATH)

cti.clean:
	rm -rf $(CTI_PATH)/.tox
	find $(CTI_PATH) -name '*.pyc' -delete
	rm -f $(CTI_TAGS)

cti.restart:
	ssh -q $(XIVO_HOSTNAME) 'systemctl restart xivo-ctid.service'

################################################################################
# xivo-ctid-ng
################################################################################

.PHONY: ctid-ng.sync ctid-ng.umount
ctid-ng.sync: sync.bootstrap ctid-ng.umount
	rsync -av --delete --exclude "*.git" --exclude "*.tox" $(CTIDNG_PATH)/ $(XIVO_HOSTNAME):~/dev/xivo-ctid-ng
	ssh -q $(XIVO_HOSTNAME) "cd ~/dev/xivo-ctid-ng && PYTHONPATH=${TMP_PYTHONPATH} python setup.py install --prefix=~/build"
	ssh -q $(XIVO_HOSTNAME) 'mount --bind ~/dev/xivo-ctid-ng/build/lib.linux-*-2.7/xivo_ctid_ng ${REMOTE_PYTHONPATH}/xivo_ctid_ng'
	ssh -q $(XIVO_HOSTNAME) "mount --bind ~/dev/xivo-ctid-ng/xivo_ctid_ng.egg-info ${REMOTE_PYTHONPATH}/xivo_ctid_ng-$(shell python $(CTIDNG_PATH)/setup.py --version).egg-info"

ctid-ng.umount:
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_ctid_ng || true'
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_ctid_ng-*.egg-info || true'

################################################################################
# xivo-dao
################################################################################
.PHONY : dao.sync dao.ctags
dao.sync:
	$(SYNC) $(DAO_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

dao.ctags:
	rm -f $(DAO_TAGS)
	ctags -o $(DAO_TAGS) -R -e $(DAO_LOCAL_PATH)


################################################################################
# xivo-manage-db
################################################################################
.PHONY : db.sync db.upgrade db.downgrade
db.sync:
	$(SYNC) $(ALEMBIC_LOCAL_PATH)/* $(XIVO_HOSTNAME):$(ALEMBIC_REMOTE_PATH)/

db.upgrade:
	ssh -q $(XIVO_HOSTNAME) 'cd /usr/share/xivo-manage-db && alembic upgrade +1'

db.downgrade:
	ssh -q $(XIVO_HOSTNAME) 'cd /usr/share/xivo-manage-db && alembic downgrade -1'

################################################################################
# consul
################################################################################

.PHONY : consul.sync consul.restart
consul.sync:
	rsync -av $(CONSUL_PATH)/debian/init $(XIVO_HOSTNAME):/etc/init.d/consul
	ssh -q $(XIVO_HOSTNAME) 'chmod +x /etc/init.d/consul'

consul.restart:
	ssh -q $(XIVO_HOSTNAME) 'service consul restart'


# xivo-dird
.PHONY : dird.sync dird.umount dird.ctags dird.clean dird.restart dird.db-upgrade dird.db-downgrade
dird.sync: dird.umount sync.bootstrap
	rsync -av --delete --exclude "*.git" --exclude "*.tox" $(DIRD_PATH)/ $(XIVO_HOSTNAME):~/dev/xivo-dird
	ssh -q $(XIVO_HOSTNAME) "cd ~/dev/xivo-dird && PYTHONPATH=${TMP_PYTHONPATH} python setup.py install --prefix=~/build"
	ssh -q $(XIVO_HOSTNAME) "mount --bind ${TMP_PYTHONPATH}/xivo_dird-*-py2.7.egg/xivo_dird ${REMOTE_PYTHONPATH}/xivo_dird"
	ssh -q $(XIVO_HOSTNAME) "mount --bind ${TMP_PYTHONPATH}/xivo_dird-*-py2.7.egg/EGG-INFO ${REMOTE_PYTHONPATH}/xivo_dird-$(shell $(DIRD_PATH)/setup.py --version).egg-info"
	ssh -q $(XIVO_HOSTNAME) "mount --bind ~/dev/xivo-dird/alembic /usr/share/xivo-dird/alembic"

dird.umount:
	ssh -q $(XIVO_HOSTNAME) "umount ${REMOTE_PYTHONPATH}/xivo_dird || true"
	ssh -q $(XIVO_HOSTNAME) "umount ${REMOTE_PYTHONPATH}/xivo_dird-*.egg-info || true"
	ssh -q $(XIVO_HOSTNAME) "umount /usr/share/xivo-dird/alembic || true"

dird.ctags: dird.clean
	ctags -o $(DIRD_TAGS) -R -e $(DIRD_PATH)/xivo_dird
	ctags -o $(DIRD_TAGS) -R -e -a $(LIB_PYTHON_LOCAL_PATH)
	ctags -o $(DIRD_TAGS) -R -e -a $(XIVO_PATH)/xivo-auth-client/xivo_auth_client
	ctags -o $(DIRD_TAGS) -R -e -a $(XIVO_PATH)/xivo-lib-rest-client/xivo_lib_rest_client
	ctags -o $(DIRD_TAGS) -R -e -a $(XIVO_PATH)/xivo-confd-client/xivo_confd_client

dird.clean:
	rm -rf $(DIRD_PATH)/.tox
	find $(DIRD_PATH) -name '*.pyc' -delete
	rm -f $(DIRD_TAGS)

dird.restart:
	ssh -q $(XIVO_HOSTNAME) 'service xivo-dird restart'

dird.db-upgrade:
	ssh -q $(XIVO_HOSTNAME) 'cd /usr/share/xivo-dird && alembic -c alembic.ini upgrade head'

dird.db-downgrade:
	ssh -q $(XIVO_HOSTNAME) 'cd /usr/share/xivo-dird && alembic -c alembic.ini downgrade -1'


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
	$(SYNC) $(XIVO_PROVD_PYTHONPATH)/provd $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-upgrade
.PHONY : upgrade.sync

upgrade.sync:
	$(SYNC) $(UPGRADE_LOCAL_PATH)/bin/ $(XIVO_HOSTNAME):/usr/bin/

################################################################################
# xivo-confd
################################################################################

.PHONY : confd.sync confd.umount confd.ctags confd.clean confd.restart
confd.sync: confd.umount sync.bootstrap
	rsync -av --delete --exclude "*.git" --exclude "*.tox" $(CONFD_PATH)/ $(XIVO_HOSTNAME):~/dev/xivo-confd
	ssh -q $(XIVO_HOSTNAME) "cd ~/dev/xivo-confd && PYTHONPATH=${TMP_PYTHONPATH} python setup.py install --prefix=~/build"
	ssh -q $(XIVO_HOSTNAME) 'mount --bind ${TMP_PYTHONPATH}/xivo_confd-*-py2.7.egg/xivo_confd ${REMOTE_PYTHONPATH}/xivo_confd'
	ssh -q $(XIVO_HOSTNAME) "mount --bind ${TMP_PYTHONPATH}/xivo_confd-*-py2.7.egg/EGG-INFO ${REMOTE_PYTHONPATH}/xivo_confd-$(shell $(CONFD_PATH)/setup.py --version).egg-info"

confd.umount:
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_confd || true'
	ssh -q $(XIVO_HOSTNAME) 'umount ${REMOTE_PYTHONPATH}/xivo_confd-*.egg-info || true'

confd.clean:
	rm -rf $(CONFD_PATH)/.tox
	find $(CONFD_PATH) -name '*.pyc' -delete
	rm -f $(CONFD_TAGS)

confd.ctags: confd.clean
	ctags -o $(CONFD_TAGS) -R -e $(CONFD_PATH)/xivo_confd
	ctags -o $(CONFD_TAGS) -R -e -a $(LIB_PYTHON_LOCAL_PATH)
	ctags -o $(CONFD_TAGS) -R -e -a $(XIVO_PATH)/xivo-auth-client/xivo_auth_client
	ctags -o $(CONFD_TAGS) -R -e -a $(XIVO_PATH)/xivo-lib-rest-client/xivo_lib_rest_client
	ctags -o $(CONFD_TAGS) -R -e -a $(XIVO_PATH)/xivo-dao/xivo_dao

confd.restart:
	ssh -q $(XIVO_HOSTNAME) 'service xivo-confd restart'


################################################################################
# xivo-sysconf
################################################################################

.PHONY : sysconf.sync
sysconf.sync:
	$(SYNC) $(SYSCONF_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# xivo-stat
.PHONY : stat.sync
stat.sync:
	$(SYNC) $(STAT_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

# asterisk
.PHONY : asterisk.clean asterisk.generate asterisk.refresh asterisk.ctags asterisk.cscope
asterisk.clean:
	rm -fr $(ASTERISK_PATH)/asterisk/tmp/

asterisk.ctags:
	rm -f $(ASTERISK_TAGS)
	ctags -o $(ASTERISK_TAGS) -R -e -a $(ASTERISK_LOCAL_PATH)

asterisk.cscope:
	rm -f $(ASTERISK_CSCOPE_FILES)
	find $(ASTERISK_LOCAL_PATH) -name "*.c" -o -name "*.h" >> $(ASTERISK_CSCOPE_FILES)

asterisk.generate:
	$(ASTERISK_PATH)/asterisk/prepare_test_sources.sh

asterisk.refresh: asterisk.clean asterisk.generate sccp.ctags sccp.cscope

################################################################################
# dialplan
################################################################################

.PHONY : dialplan.sync dialplan.reload dialplan.reload dialplan.umount
dialplan.reload:
	ssh -q $(XIVO_HOSTNAME) 'asterisk -rx "dialplan reload"'

dialplan.sync: dialplan.umount sync.bootstrap
	rsync -av --delete --exclude "*.git" --exclude "*.tox" $(DIALPLAN_LOCAL_PATH)/ $(XIVO_HOSTNAME):~/dev/dialplan
	ssh -q $(XIVO_HOSTNAME) 'mount --bind ~/dev/dialplan/ $(DIALPLAN_REMOTE_PATH)'

dialplan.umount:
	ssh -q $(XIVO_HOSTNAME) 'umount $(DIALPLAN_REMOTE_PATH) || true'


################################################################################
# lib-rest-client
################################################################################

.PHONY : lib-rest-client.sync
lib-rest-client.sync:
	$(SYNC) $(LIB_REST_CLIENT_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)


.PHONY : dird-client.sync
dird-client.sync:
	$(SYNC) --delete $(XIVO_PATH)/xivo-dird-client $(XIVO_HOSTNAME):/tmp
	ssh $(XIVO_HOSTNAME) 'cd /tmp/xivo-dird-client && python setup.py develop'


.PHONY : confd-client.sync
confd-client.sync:
	$(SYNC) $(CONFD_CLIENT_LOCAL_PATH) $(XIVO_HOSTNAME):$(PYTHON_PACKAGES)

.PHONY : auth-client.sync
auth-client.sync:
	$(SYNC) --delete $(XIVO_PATH)/xivo-auth-client $(XIVO_HOSTNAME):/tmp
	ssh $(XIVO_HOSTNAME) 'cd /tmp/xivo-auth-client && python setup.py develop'

.PHONY : monitoring.sync
monitoring.sync:
	$(SYNC) $(XIVO_PATH)/xivo-monitoring/checks/* $(XIVO_HOSTNAME):/usr/share/xivo-monitoring/checks/
