#!/bin/bash

if [ -z "$1" ]
    then
       GIT_BRANCH=${GIT_BRANCH='master'}
    else
       GIT_BRANCH="$1"
fi
export GIT_BRANCH=${GIT_BRANCH}
export FORCE=true
COUNT=`cat counter.tmp`
CURRENT_BUILD=$(expr $COUNT + 1)


read -p "Are you sure no other build is in progress? Y/N? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "\nHint: stopping the current build can be done by running stop.sh"
    echo "exiting..."
    exit 1
fi

read -p "Do you want to run mock SSD build? Y/N? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "\nrunning regular build"
else
   echo -e "\nrunning mock SSD build"
   export TGRID_TARGET_JVM="7_Sun8_MockSSD"
   export TGRID_SUITE_CUSTOM_SYSPROPS="-Dcom.gs.OffHeapData=true -Dcom.gs.OffHeapDataNewInterface=true -Dcom.gs.enabled-backward-space-lifecycle-admin=true -Dcom.gs.DirectPersistencyLastPrimaryStateDir=/tmp/lastprimary"
   EXCLUDE1="com.gigaspaces.test.basic.EvictOnlyLRUSpaceTest*;com.gigaspaces.test.basic.RecentUpdatesTest*;com.gigaspaces.test.basic.UIDMatchTest*;com.gigaspaces.test.cacheloader.CacheLoaderHierarchyTest*;com.gigaspaces.test.cacheloader.CacheLoaderReplicatedNodes*;com.gigaspaces.test.cacheloader.CacheLoaderSQLQueryTest*;com.gigaspaces.test.cacheloader.ExerciseCacheLoader*;com.gigaspaces.test.cacheloader.ExerciseMapCacheLoader*;com.gigaspaces.test.cacheloader.InitialLoadHirarchyObjectsTest*;com.gigaspaces.test.cacheloader.datasource.EDSLRUAGFalseCentralDBPartialUpdateTest*;com.gigaspaces.test.cacheloader.datasource.EDSLRUAGFalseNonCentralDBPartialUpdateTest*;com.gigaspaces.test.cacheloader.datasource.EDSLRUAGTrueCentralDBPartialUpdateTest*;com.gigaspaces.test.cacheloader.datasource.EDSLRUAGTrueNonCentralDBPartialUpdateTest*;com.gigaspaces.test.cacheloader.datasource.EDSNullablePojoTest*;com.gigaspaces.test.cacheloader.datasource.EmptyLRUInitialLoadTest*;com.gigaspaces.test.cacheloader.datasource.ErrorsInInitialLoadTest*;com.gigaspaces.test.cacheloader.datasource.FailOverMirrorAndThenStopFeederTest*;com.gigaspaces.test.cacheloader.datasource.FifoLruEDSTest*;com.gigaspaces.test.cacheloader.datasource.MirrorLoadTest*;com.gigaspaces.test.cacheloader.datasource.NestedQueryEDSTest*;com.gigaspaces.test.cacheloader.datasource.ReadByPassTest*;com.gigaspaces.test.transaction.LRUMultiThreadedTest*;com.gigaspaces.test.unique_constraint.UniqueConstraintLRUNegativeTest*;com.gigaspaces.test.view.local.EDSLRULocalViewReliabilityFailOverTest*;com.gigaspaces.test.view.local.EDSLRULocalViewReliabilityTest*;com.gigaspaces.test.lru*;com.gigaspaces.test.cacheloader.datasource.ReadOnlyDatasourceTest*;com.gigaspaces.test.cacheloader.datasource.SpaceRoutingTest*;com.gigaspaces.test.cacheloader.datasource.UidAutoGenerateEdsTest*;com.gigaspaces.test.cluster.replication.reliable_async*;com.gigaspaces.test.change.persistency.PersistencyLruChangeAutoGenFalseTest*;com.gigaspaces.test.change.persistency.PersistencyLruChangeAutoGenTrueTest*;com.gigaspaces.test.cluster.failover.TransactionFailOverLoadWithMirrorDownTest*;com.gigaspaces.test.cluster.failover.TransactionFailOverLoadWithMirrorDownWithRemoteTxnMgrTest*;com.gigaspaces.test.cluster.failover.TransactionFailOverLoadWithMirrorUpTest*;com.gigaspaces.test.cluster.failover.TransactionFailOverLoadWithMirrorUpWithRemoteTxnMgrTest*;com.gigaspaces.test.cluster.lb.LB_primaryBackup_WarmInitTest*;com.gigaspaces.test.cluster.recovery.PrimaryBackupClusterRecovery*;com.gigaspaces.test.cluster.replication.basic_replication.LocalViewSpaceWithMirrorRemoveTest*;com.gigaspaces.test.cluster.replication.primary_backup.DropStayBlockedTargetInSync*;com.gigaspaces.test.writeMultipleTimeout.mirror.WriteMultipleTimeoutMirrorTest*;com.gigaspaces.test.writeMultipleTimeout.mirror.WriteMultipleTimeoutMirrorPartialUpdateTest*;com.gigaspaces.test.transaction.TransactionMirrorBulkSizeTest*;"
   EXCLUDE2="com.gigaspaces.test.support.fs.case6483.ReadByIdObjectNotInSpaceTest*;com.gigaspaces.test.support.commerzebankcase7833.DirectPersistencyLruCentralDistTransactionTest*;com.gigaspaces.test.support.cabank.case6613.PartialUpdateTest*;com.gigaspaces.test.support.cabank.case6500.QueryParamTest*;com.gigaspaces.test.support.betamedia.case8555.LeaseCancelAfterEvictTest*;com.gigaspaces.test.support.betamedia.case8439.ChangeSwapAndMirrorTest*;com.gigaspaces.test.support.barclays.LruLeaseTest*;com.gigaspaces.test.support.barclays.Case8259*;com.gigaspaces.test.support.SocieteGenerale.Case4232.SimpleReader*;com.gigaspaces.test.space_filter.Filters*;com.gigaspaces.test.space_api.GetRuntimeInfoTest*;com.gigaspaces.test.redolog.RedoLogMonitorBlockMirrorDropBackupTest*;com.gigaspaces.test.persistent.UnsafeWriteUpdateOnlyTest*;com.gigaspaces.test.persistent.BasicUnsafeWriteTest*;com.gigaspaces.test.persistent.BasicUnsafeWriteMultipleTest*;com.gigaspaces.test.persistency.sharediterator.SharedIteratorModeEDSTest*;com.gigaspaces.test.persistency.cassandra.SpaceCassandraPojoInitalLoadTest*;com.gigaspaces.test.persistency.cassandra.SpaceCassandraLoadTest*;com.gigaspaces.test.persistency.cassandra.SpaceCassandraDocumentInitalLoadTest*;com.gigaspaces.test.persistency.cassandra*;com.gigaspaces.test.mem_usage.MemoryManagerReadThruTest*;com.gigaspaces.test.mem_usage.BackupMemoryManagerTest*;com.gigaspaces.test.lease*;com.gigaspaces.test.change.basic.ChangeMirrorSpecificSupportTest*;com.gigaspaces.test.cluster.replication.swap.SwapRedoLogNotifyTemplateTest*;com.gigaspaces.test.cluster.replication.sync_replication.FailOverBackupTest*;com.gigaspaces.test.database.sql.SQLQueryEdsCollectionQuery*;com.gigaspaces.test.datasource.MissingTypeDescMirrorDelegateToSyncEndpointTest*;com.gigaspaces.test.datasource.SynchronizationStorageAdapterInitialMetadataLoadTest*;com.gigaspaces.test.datasource.SynchronizationStorageAdapterSyncTest*;com.gigaspaces.test.datasource.SynchronizationStorageAdapterTest*;com.gigaspaces.test.fifo.LRUFifoTransientTest*;com.gigaspaces.test.indexing.DynamicIndexInheritanceLRUPersistentTest*;com.gigaspaces.test.indexing.IndexUpdateEDSTest*;com.gigaspaces.test.indexing.UniqueIndexBasicTest*;com.gigaspaces.test.cleanup.MemoryCleanupAfterShutdown*;com.gigaspaces.test.blobstore.zetascale*;com.gigaspaces.test.clear_by_id.ClearByIdsExceptionTest*;com.gigaspaces.test.indexing.IllegalIndexValueChangeTest*;"
  export TGRID_SUITE_CUSTOM_EXCLUDE="$EXCLUDE1$EXCLUDE2"
fi

echo "EXCLUDE: ${TGRID_SUITE_CUSTOM_EXCLUDE}"

echo -e "\nRunning build ${CURRENT_BUILD}"
mkdir -p -v /home/xap/buildlogs/${CURRENT_BUILD}
build_logdir="/home/xap/buildlogs/${CURRENT_BUILD}"
echo "-- redirecting output to ${build_logdir} --"
sleep 10
echo "-- build logs at ${build_logdir}/build.log --"
./run_build_process.sh &> ${build_logdir}/build.log

