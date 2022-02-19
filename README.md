# Signomix IoT Platform (target architecture)

**IoT & data management platform**

>*Signomix is in the process of refactoring, including migration to the latest version of Cricket MSF and splitting it into a set of microservices. Stay tuned.*

The target platform architecture will consist of the microservices listed below. 

|Component|Version|Description|
|---|---|---|
|[signomix-ta-app](https://github.com/signomix/signomix-ta-app)|1.0.3|Web GUI|
|[signomix-ta-receiver](https://github.com/signomix/signomix-ta-receiver)||IoT data receiver service|
|[signomix-ta-provider](https://github.com/signomix/signomix-ta-provider)||IoT data provider service|
|[signomix-ta-rabbitmq](https://github.com/signomix/signomix-ta-rabbitmq)|1.0.0|Message broker|
|[signomix-ta-ms](https://github.com/signomix/signomix-ta-ms)|1.0.0|Messaging service|
|[signomix-ta-ps](https://github.com/signomix/signomix-ta-ps)|1.2.0.10|Public service (home page, blog)|
|[signomix-proxy](https://github.com/signomix/signomix-proxy)|1.1.2|Reverse Proxy & API Gateway service|
|[signomix-database](https://github.com/signomix/signomix-database)|1.0.5|Database|
|[signomix-ta-adm](https://github.com/signomix/signomix-ta-adm)||Administration: the service management|
|[signomix](https://github.com/signomix/signomix)|1.2.226|Previous version containing the following components functionalities: signomix-ta-provider, signomix-ta-receiver, signomix-ta-adm.|

```mermaid
flowchart LR
  info1[the diagram will be updated]
  signomix-proxy
  signomix{{signomix}}
  ta-ps{{signomix-ta-ps}}
  ta-app{{signomix-ta-app}}
  ta-adm{{signomix-ta-adm}}
  ta-receiver{{signomix-ta-receiver}}
  ta-provider{{signomix-ta-provider}}
  ta-mq{{signomix-rabbitmq}}
  ta-ms{{signomix-ta-ms}}
  ta-database[(signomix-database)]
  client-->signomix-proxy
  signomix-proxy-->signomix
  signomix-proxy-->ta-ps
  signomix-proxy-->ta-app
  signomix-proxy-->ta-adm
  signomix-proxy-->ta-receiver
  signomix-proxy-->ta-provider
  signomix-->ta-mq
  ta-adm-->ta-mq
  ta-provider-->ta-mq
  ta-receiver-->ta-mq
  ta-mq-->ta-ms
  ta-mq-->ta-adm
  ta-provider-->ta-database
  ta-receiver-->ta-database
  signomix-->ta-database
  ta-adm-->ta-database
  ta-ms-->SMTP
  ta-ms-->Discord
  ta-ms-->Slack
  ta-ms-->Pushover
  ta-ms-->Telegram
  ta-ms-->Webhook

```
