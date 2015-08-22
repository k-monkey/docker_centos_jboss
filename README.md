docker build -t jboss-test01 .

docker run -it -p 8080:8081 -v /Users/m849876/workspace/VMs/orders-jboss/local:/local1/ jboss-test01
