# Hadoop in Secure Mode

Apache Hadoop 3.3.0: [Hadoop in Secure Mode](https://hadoop.apache.org/docs/r3.3.0/hadoop-project-dist/hadoop-common/SecureMode.html)

하둡을 보안 모드로 실행할 때는 모든 하둡 서비스와 사용자들은 Kerberos를 이용해서 인증을 해야 한다.

---

## Download

`ansible/files/dist` 디렉터리를 생성한다.

### Hadoop 3.3.0

`hadoop-3.3.0.tar.gz` 파일을 `ansible/files/dist` 경로에 다운로드 한다.

- [Hadoop Mirrors](http://www.apache.org/dyn/closer.cgi/hadoop/common/)
- Index of [/hadoop/common/hadoop-3.3.0](https://downloads.apache.org/hadoop/common/hadoop-3.3.0/)

### Apache Commons Daemon 1.2.3

`commons-daemon-1.2.3-src.tar.gz` 파일을 `ansible/files/dist` 경로에 다운로드 한다.

- Index of [/dist/commons/daemon/source](https://downloads.apache.org/commons/daemon/source/)

---

## Software

Vagrant와 VirtualBox, Ansible을 사용하여 로컬 환경에 가상머신 클러스터를 구축한다.

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### vagrant 명령어

```bash
vagrant up # VM 프로비전
vagrant status # VM 상태
vagrant ssh my # VM 연결
vagrant destroy -f # VM 초기화
```

---

## 서버 실행

### HDFS 네임노드 초기화

`/tmp/hadoop-hdfs` 디렉터리가 존재하지 않는다면 다음 명령 실행한다:

```bash
sudo su - hdfs -c '/etc/hadoop/bin/hdfs namenode -format -force'
```

### HDFS 네임노드 실행

```bash
sudo su - hdfs -c '/etc/hadoop/bin/hdfs --daemon start namenode'
```

### HDFS 데이터노드 실행

```bash
sudo /etc/hadoop/bin/hdfs --daemon start namenode
```

### HDFS 파일시스템 설정

HDFS를 다음 구조로 초기화 한다:

```bash
sudo su - hdfs -c '/vagrant/ansible/files/script/setup.hdfs.sh'
```

#### HDFS 파일시스템

```bash
sudo su - hdfs -c '/etc/hadoop/bin/hdfs dfs -ls -R /'
```

```bash
drwxrwxrwt   - mapred hadoop    0 2020-11-03 09:09 /mr-history
drwxr-x---   - mapred hadoop    0 2020-11-03 09:09 /mr-history/done
drwxrwxrwt   - mapred hadoop    0 2020-11-03 09:09 /mr-history/tmp
drwxrwxrwt   - hdfs   hadoop    0 2020-11-03 13:49 /tmp
drwxrwx---   - mapred hadoop    0 2020-11-03 13:49 /tmp/hadoop-yarn
drwxrwx---   - mapred hadoop    0 2020-11-03 13:49 /tmp/hadoop-yarn/staging
drwxrwx---   - mapred hadoop    0 2020-11-03 13:49 /tmp/hadoop-yarn/staging/history
drwxrwx---   - mapred hadoop    0 2020-11-03 13:49 /tmp/hadoop-yarn/staging/history/done
drwxrwxrwt   - mapred hadoop    0 2020-11-03 13:49 /tmp/hadoop-yarn/staging/history/done_intermediate
drwxrwxrwt   - yarn   hadoop    0 2020-11-03 09:08 /tmp/logs
drwxr-xr-x   - hdfs   hadoop    0 2020-11-03 09:08 /user
drwx------   - hdfs   hadoop    0 2020-11-03 09:08 /user/hdfs
drwx------   - mapred hadoop    0 2020-11-03 09:08 /user/mapred
drwx------   - yarn   hadoop    0 2020-11-03 09:08 /user/yarn
```

### YARN 리소스매니저 실행

```bash
sudo su - yarn -c '/etc/hadoop/bin/yarn --daemon start resourcemanager'
```

### YARN 노드매니저 실행

```bash
sudo /etc/hadoop/bin/yarn --daemon start nodemanager
```

### MAPRED 맵리듀스 잡 히스토리 서버 실행

```bash
sudo su - mapred -c '/etc/hadoop/bin/mapred --daemon start historyserver'
```

---

## 실행 중인 서버 목록

```bash
jps # Java Virtual Machine Process Status Tool
```

```bash
4706 Jps
4436 NodeManager
3784 NameNode
4616 JobHistoryServer
4121 ResourceManager
3981 Secur
```

---

## Web Interfaces

| Daemon | Web Interface | Default HTTP port | Localhost Link |
|---|---|---|---|
| NameNode | `http://nn_host:port/` | 9870 | [http://localhost:9870](http://localhost:9870) |
| ResourceManager | `http://rm_host:port/` | 8088 | [http://localhost:8088](http://localhost:8088) |
| MapReduce JobHistory Server | `http://jhs_host:port/` | 19888 | [http://localhost:19888](http://localhost:19888) |

---

## 테스트

1. 권한 없는 HDFS 접근
1. 권한 획득
1. HDFS 접근
1. MapReduce 작업 실행
1. 결과 확인

### 환경변수 설정

```bash
export HADOOP_HOME=/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
```

### HDFS 접근 확인

`vagrant` 유저는 HDFS에 접근할 수 없다.

```bash
hdfs dfs -ls -R /
```

```bash
2020-11-03 14:17:18,317 WARN ipc.Client: Exception encountered while connecting to the server 
org.apache.hadoop.security.AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]
```

### HDFS 사용자 디렉터리 생성

```bash
sudo su - hdfs -c '/etc/hadoop/bin/hdfs dfs -mkdir /user/vagrant'
sudo su - hdfs -c '/etc/hadoop/bin/hdfs dfs -chown vagrant:hadoop /user/vagrant'
sudo su - hdfs -c '/etc/hadoop/bin/hdfs dfs -chmod 700 /user/vagrant'
```

### vagrant keytab 생성

```bash
sudo kadmin -p admin/admin -w password -q 'addprinc -pw password vagrant/my.example.com@EXAMPLE.COM'
sudo kadmin -p admin/admin -w password -q 'ktadd -k /home/vagrant/vagrant.keytab vagrant/my.example.com@EXAMPLE.COM'
sudo chown vagrant:vagrant /home/vagrant/vagrant.keytab
```

### Kerberos 티켓 생성

```bash
kinit -k -t /home/vagrant/vagrant.keytab vagrant/my.example.com@EXAMPLE.COM
```

### Kerberos 티켓 확인

```bash
klist
```

```bash
Ticket cache: FILE:/tmp/krb5cc_1000
Default principal: vagrant/my.example.com@EXAMPLE.COM

Valid starting     Expires            Service principal
11/03/20 14:37:44  11/04/20 02:37:44  krbtgt/EXAMPLE.COM@EXAMPLE.COM
	renew until 11/04/20 14:37:44
```

### HDFS 접근 확인

```bash
hdfs dfs -ls -R /
```

```bash
drwxrwxrwt   - mapred hadoop          0 2020-11-03 09:09 /mr-history
drwxr-x---   - mapred hadoop          0 2020-11-03 09:09 /mr-history/done
ls: Permission denied: user=vagrant, access=READ_EXECUTE, inode="/mr-history/done":mapred:hadoop:drwxr-x---
drwxrwxrwt   - mapred hadoop          0 2020-11-03 09:09 /mr-history/tmp
drwxrwxrwt   - hdfs   hadoop          0 2020-11-03 13:49 /tmp
drwxrwx---   - mapred hadoop          0 2020-11-03 13:49 /tmp/hadoop-yarn
ls: Permission denied: user=vagrant, access=READ_EXECUTE, inode="/tmp/hadoop-yarn":mapred:hadoop:drwxrwx---
drwxrwxrwt   - yarn   hadoop          0 2020-11-03 09:08 /tmp/logs
drwxr-xr-x   - hdfs   hadoop          0 2020-11-03 14:19 /user
drwx------   - hdfs    hadoop          0 2020-11-03 09:08 /user/hdfs
ls: Permission denied: user=vagrant, access=READ_EXECUTE, inode="/user/hdfs":hdfs:hadoop:drwx------
drwx------   - mapred  hadoop          0 2020-11-03 09:08 /user/mapred
ls: Permission denied: user=vagrant, access=READ_EXECUTE, inode="/user/mapred":mapred:hadoop:drwx------
drwx------   - vagrant hadoop          0 2020-11-03 14:19 /user/vagrant
drwx------   - yarn    hadoop          0 2020-11-03 09:08 /user/yarn
ls: Permission denied: user=vagrant, access=READ_EXECUTE, inode="/user/yarn":yarn:hadoop:drwx------
```

### 파일 업로드

```bash
hdfs dfs -mkdir -p /user/vagrant/input
hdfs dfs -copyFromLocal $HADOOP_HOME/etc/hadoop/*.xml input
```

확인:

```bash
hdfs dfs -ls /user/vagrant/input
```

### 맵리듀스 작업 실행

작업 디렉터리 권한 추가:

```bash
sudo su - hdfs -c '/etc/hadoop/bin/hdfs dfs -chmod -R 777 /tmp/hadoop-yarn'
```

맵리듀스 예제 실행

```bash
hadoop jar \
$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.0.jar \
grep input output 'dfs[a-z.]+'
```

#### 실행 로그

```log
2020-11-03 14:50:04,558 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at /0.0.0.0:8032
2020-11-03 14:50:04,845 INFO hdfs.DFSClient: Created token for vagrant: HDFS_DELEGATION_TOKEN owner=vagrant/my.example.com@EXAMPLE.COM, renewer=yarn, realUser=, issueDate=1604415004831, maxDate=1605019804831, sequenceNumber=3, masterKeyId=4 on 192.168.9.100:9000
```

```log
2020-11-03 14:50:07,437 INFO mapreduce.Job: Running job: job_1604411286063_0001
2020-11-03 14:50:15,688 INFO mapreduce.Job: Job job_1604411286063_0001 running in uber mode : false
2020-11-03 14:50:15,689 INFO mapreduce.Job:  map 0% reduce 0%
2020-11-03 14:50:27,950 INFO mapreduce.Job:  map 60% reduce 0%
2020-11-03 14:50:37,062 INFO mapreduce.Job:  map 80% reduce 0%
2020-11-03 14:50:38,078 INFO mapreduce.Job:  map 100% reduce 100%
2020-11-03 14:50:40,098 INFO mapreduce.Job: Job job_1604411286063_0001 completed successfully
```

```log
Map-Reduce Framework
		Map input records=19
		Map output records=19
		Map output bytes=701
		Map output materialized bytes=745
		Input split bytes=137
		Combine input records=0
		Combine output records=0
		Reduce input groups=2
		Reduce shuffle bytes=745
		Reduce input records=19
		Reduce output records=19
		Spilled Records=38
		Shuffled Maps =1
		Failed Shuffles=0
		Merged Map outputs=1
	File Input Format Counters 
		Bytes Read=939
	File Output Format Counters 
		Bytes Written=587
```

### 결과 확인

#### output 디렉터리

```bash
hdfs dfs -ls output
```

```bash
Found 2 items
-rw-r--r--   1 vagrant hadoop          0 2020-11-03 14:51 output/_SUCCESS
-rw-r--r--   1 vagrant hadoop        587 2020-11-03 14:50 output/part-r-00000
```

#### 맵리듀스 결과 파일

```bash
hdfs dfs -cat output/*
```

```txt
2	dfs.web.authentication.kerberos.principal
1	dfsadmin
1	dfs.secondary.namenode.keytab.file
1	dfs.secondary.namenode.kerberos.principal
1	dfs.replication
1	dfs.namenode.secondary.https
1	dfs.namenode.secondary.http
1	dfs.namenode.keytab.file
1	dfs.namenode.kerberos.principal
1	dfs.namenode.kerberos.internal.spnego.principal
1	dfs.encrypt.data.transfer
1	dfs.datanode.keytab.file
1	dfs.datanode.kerberos.principal
1	dfs.datanode.https.address
1	dfs.datanode.http.address
1	dfs.datanode.data.dir.perm
1	dfs.datanode.address
1	dfs.data.transfer.protection
1	dfs.block.access.token.enable
```

### Web Interface 확인

#### ResourceManager

![](images/ResourceManager.png)

#### JobHistory

![](images/JobHistory.png)
