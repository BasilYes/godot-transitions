@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Transactions", "res://addons/transactions/transaction.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("Transactions")
