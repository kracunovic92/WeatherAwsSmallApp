import pytest
import requests
from unittest.mock import Mock
from externalAPI.python.externalAPI.get_visitor_data import get_tourist_for_day 


def test_get_tourist_for_day_success(mocker):

    mock_response_data = {
        "for_date": "2022-05-03",
        "info": [
            {"name": "Paris", "estimated_no_people": 1200},
            {"name": "Berlin", "estimated_no_people": 800}
        ]
    }

    mock_response = Mock(spec=requests.Response)
    mock_response.status_code = 200
    mock_response.json.return_value = mock_response_data

    mocker.patch('requests.get', return_value=mock_response)

    result = get_tourist_for_day('2022-05-03')

    assert result == mock_response_data
    assert "Paris" in [city['name'] for city in result['info']]
    assert "Berlin" in [city['name'] for city in result['info']]


def test_get_tourist_for_day_failure(mocker):
    
    mock_response = Mock(spec=requests.Response)
    mock_response.status_code = 500  
    mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError("Server Error")

    mocker.patch('requests.get', return_value=mock_response)
    with pytest.raises(requests.exceptions.HTTPError):
        get_tourist_for_day('2022-05-03')

