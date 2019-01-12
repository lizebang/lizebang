---
title: 'Kubernetes Concepts Content'
slug: kubernetes-concepts
draft: true
date: 2019-01-10
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
  - concepts
keywords:
  - kubernetes
  - concepts
---

Kubernetes Concepts Content

<!--more-->

## Concepts

| source   | translation                                           | commit |
| :------- | :---------------------------------------------------- | :----- |
| Concepts | [kubernetes 概念](/2018/08/kubernetes_concepts_index) | #9445  |

## Overview

| source                | translation                                                                      | commit |
| :-------------------- | :------------------------------------------------------------------------------- | :----- |
| What is Kubernetes?   | [什么是 Kubernetes ？](/2018/08/kubernetes_concepts_overview_what-is-kubernetes) | #11399 |
| Kubernetes Components | [Kubernetes 组件](/2018/08/kubernetes_concepts_overview_components)              | #8787  |
| The Kubernetes API    | [Kubernetes API](/2018/08/kubernetes_concepts_overview_kubernetes-api)           | #11835 |

### Working with Kubernetes Objects

| source                           | translation                                                                                         | commit |
| :------------------------------- | :-------------------------------------------------------------------------------------------------- | :----- |
| Understanding Kubernetes Objects | [Kubernetes 对象](/2018/08/kubernetes_concepts_overview_working-with-objects_kubernetes-objects)    | #9954  |
| Names                            | [Kubernetes 对象名称](/2018/08/kubernetes_concepts_overview_working-with-objects_names)             | #10720 |
| Namespaces                       | [Kubernetes 命名空间](/2018/08/kubernetes_concepts_overview_working-with-objects_namespaces)        | #10720 |
| Labels and Selectors             | [Kubernetes 标签和选择器](/2018/08/kubernetes_concepts_overview_working-with-objects_labels)        | #11719 |
| Annotations                      | [Kubernetes 注解](/2018/09/kubernetes_concepts_overview_working-with-objects_annotations)           | #11719 |
| Field Selectors                  | [Kubernetes 字段选择器](/2018/09/kubernetes_concepts_overview_working-with-objects_field-selectors) | #9174  |
| Recommended Labels               | [Kubernetes 推荐标签](/2018/09/kubernetes_concepts_overview_working-with-objects_common-labels)     | #9482  |

### Object Management Using kubectl

| source                                                                 | translation                                                                                                                      | commit |
| :--------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------- | :----- |
| Kubernetes Object Management                                           | [Kubernetes 对象管理](/2018/09/kubernetes_concepts_overview_object-management-kubectl_overview)                                  | #11401 |
| Managing Kubernetes Objects Using Imperative Commands                  | [使用命令式指令管理 Kubernetes 对象](/2018/09/kubernetes_concepts_overview_object-management-kubectl_imperative-command)         | #10982 |
| Imperative Management of Kubernetes Objects Using Configuration Files  | [使用配置文件对 Kubernetes 对象的命令式管理](/2018/09/kubernetes_concepts_overview_object-management-kubectl_imperative-config)  | #9482  |
| Declarative Management of Kubernetes Objects Using Configuration Files | [使用配置文件对 Kubernetes 对象的声明式管理](/2018/09/kubernetes_concepts_overview_object-management-kubectl_declarative-config) | #11805 |

## Kubernetes Architecture

| source                                           | translation | commit |
| :----------------------------------------------- | :---------- | :----- |
| Nodes                                            |             |        |
| Master-Node communication                        |             |        |
| Concepts Underlying the Cloud Controller Manager |             |        |

## Containers

| source                          | translation                                                                                        | commit |
| :------------------------------ | :------------------------------------------------------------------------------------------------- | :----- |
| Images                          | [Kubernetes 镜像](/2018/09/kubernetes_concepts_containers_images)                                  | #11808 |
| Container Environment Variables | [Kubernetes 容器环境变量](/2018/09/kubernetes_concepts_containers_container-environment-variables) | #10720 |
| Runtime Class                   |                                                                                                    |        |
| Container Lifecycle Hooks       | [容器生命周期的钩子](/2018/09/kubernetes_concepts_containers_container-container-lifecycle-hooks)  | #10720 |

## Workloads

### Pods

| source          | translation                                                                            | commit |
| :-------------- | :------------------------------------------------------------------------------------- | :----- |
| Pod Overview    | [Kubernetes Pod 概述](/2018/09/kubernetes_concepts_workloads_pods_pod-overview)        | #10731 |
| Pods            | [Kubernetes Pods](/2018/09/kubernetes_concepts_workloads_pods_pod)                     | #11923 |
| Pod Lifecycle   | [Kubernetes Pod 的生命周期](/2018/09/kubernetes_concepts_workloads_pods_pod-lifecycle) | #11525 |
| Init Containers | [Kubernetes Init 容器](/2018/09/kubernetes_concepts_workloads_pods_init-containers)    | #10720 |
| Pod Preset      | [Kubernetes Pod Preset](/2018/09/kubernetes_concepts_workloads_pods_podpreset)         | #9482  |
| Disruptions     |                                                                                        |        |

### Controllers

| source                                | translation | commit |
| :------------------------------------ | :---------- | :----- |
| ReplicaSet                            |             |        |
| ReplicationController                 |             |        |
| Deployments                           |             |        |
| StatefulSets                          |             |        |
| DaemonSet                             |             |        |
| Garbage Collection                    |             |        |
| TTL Controller for Finished Resources |             |        |
| Jobs - Run to Completion              |             |        |
| CronJob                               |             |        |

## Services, Load Balancing, and Networking

| source                                            | translation | commit |
| :------------------------------------------------ | :---------- | :----- |
| Services                                          |             |        |
| DNS for Services and Pods                         |             |        |
| Connecting Applications with Services             |             |        |
| Ingress                                           |             |        |
| Network Policies                                  |             |        |
| Adding entries to Pod /etc/hosts with HostAliases |             |        |

## Storage

| source                      | translation | commit |
| :-------------------------- | :---------- | :----- |
| Volumes                     |             |        |
| Persistent Volumes          |             |        |
| Volume Snapshots            |             |        |
| Storage Classes             |             |        |
| Volume Snapshot Classes     |             |        |
| Dynamic Volume Provisioning |             |        |
| Node-specific Volume Limits |             |        |

## Configuration

| source                                           | translation | commit |
| :----------------------------------------------- | :---------- | :----- |
| Configuration Best Practices                     |             |        |
| Managing Compute Resources for Containers        |             |        |
| Assigning Pods to Nodes                          |             |        |
| Taints and Tolerations                           |             |        |
| Secrets                                          |             |        |
| Organizing Cluster Access Using kubeconfig Files |             |        |
| Pod Priority and Preemption                      |             |        |
| Scheduler Performance Tuning                     |             |        |

## Policies

| source                | translation | commit |
| :-------------------- | :---------- | :----- |
| Resource Quotas       |             |        |
| Pod Security Policies |             |        |

## Cluster Administration

| source                                 | translation                                                                                                    | commit |
| :------------------------------------- | :------------------------------------------------------------------------------------------------------------- | :----- |
| Cluster Administration Overview        | [Kubernetes 群集管理概述](/2018/09/kubernetes_concepts_cluster-administration_cluster-administration-overview) | #10248 |
| Certificates                           | [Kubernetes 证书](/2018/09/kubernetes_concepts_cluster-administration_certificates)                            | #11075 |
| Cloud Providers                        |                                                                                                                |        |
| Managing Resources                     | [Kubernetes 管理资源](/2018/09/kubernetes_concepts_cluster-administration_manage-deployment)                   | #9482  |
| Cluster Networking                     |                                                                                                                |        |
| Logging Architecture                   |                                                                                                                |        |
| Configuring kubelet Garbage Collection |                                                                                                                |        |
| Federation                             |                                                                                                                |        |
| Proxies in Kubernetes                  |                                                                                                                |        |
| Controller manager metrics             |                                                                                                                |        |
| Installing Addons                      |                                                                                                                |        |

## Extending Kubernetes

| source                            | translation | commit |
| :-------------------------------- | :---------- | :----- |
| Extending your Kubernetes Cluster |             |        |
| Service Catalog                   |             |        |

### Extending the Kubernetes API

| source                                                  | translation | commit |
| :------------------------------------------------------ | :---------- | :----- |
| Extending the Kubernetes API with the aggregation layer |             |        |
| Custom Resources                                        |             |        |

## Compute, Storage, and Networking Extensions

| source          | translation | commit |
| :-------------- | :---------- | :----- |
| Network Plugins |             |        |
| Device Plugins  |             |        |
