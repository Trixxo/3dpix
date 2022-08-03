class_name ArrayExtra

# Find the first element in array on which calling 
# the method specified by method_name returns true.
static func find_by_method(array: Array, method_name: String):
    for elem in array:
        if elem.call(method_name):
            return elem
    return null

# Find the first element in array on which calling 
# the method specified by method_name returns true.
static func filter_by_method(array: Array, method_name: String):
    var results = []
    for elem in array:
        if elem.call(method_name):
            results.append(elem)
    return results