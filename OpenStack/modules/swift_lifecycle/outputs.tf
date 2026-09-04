output "container_name" {
  value = openstack_objectstorage_container_v1.this.name
}

output "versions_container_name" {
  value = openstack_objectstorage_container_v1.versions.name
}
