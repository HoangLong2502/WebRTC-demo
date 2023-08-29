
def convert_response(message, status_code, data=None, count=None):
    """
        We want to convert body response to normalization.
    """
    
    response = {
        "message": message,
        "code": status_code,
    }
    
    if data is not None:
        response.update({"data": data})
    if count is not None:
        response.update({"count": count})
        
    return response