package org.jboss.demo.fsw.angrytweet.model;

import java.util.Date;

public class ProviderServiceTicket {
    
    private String extId;
    
    private String service;
    
    private String requester;
    
    private String customer;
    
    private String areaCode;
    
    private String comments;
    
    private String channelIn;
    
    private Date submitted;
    
    private String channelOut;
    
    private String email;
    
    private int urgent;
    
    private boolean error = false;
    
    private String errorString;
    
    public String getExtId() {
        return extId;
    }

    public void setExtId(String extId) {
        this.extId = extId;
    }

    public String getService() {
        return service;
    }

    public void setService(String service) {
        this.service = service;
    }

    public String getRequester() {
        return requester;
    }

    public void setRequester(String requester) {
        this.requester = requester;
    }

    public String getAreaCode() {
        return areaCode;
    }

    public void setAreaCode(String areaCode) {
        this.areaCode = areaCode;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public String getChannelIn() {
        return channelIn;
    }

    public void setChannelIn(String channelIn) {
        this.channelIn = channelIn;
    }

    public int getUrgent() {
        return urgent;
    }

    public void setUrgent(int urgent) {
        this.urgent = urgent;
    }

    public Date getSubmitted() {
        return submitted;
    }

    public void setSubmitted(Date submitted) {
        this.submitted = submitted;
    }
    
    public String getCustomer() {
        return customer;
    }

    public void setCustomer(String customer) {
        this.customer = customer;
    }
    
    public String getChannelOut() {
        return channelOut;
    }

    public void setChannelOut(String channelOut) {
        this.channelOut = channelOut;
    }
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public String getErrorString() {
        return errorString;
    }

    public void setErrorString(String errorString) {
        this.errorString = errorString;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        return sb.append("{")
            .append("id: \"").append(extId)
            .append("\", requester: \"").append(requester)
            .append("\", channelIn: \"").append(channelIn)
            .append("\", channelOut: \"").append(channelOut)
            .append("\", customer: \"").append(customer)
            .append("\", service: \"").append(service)
            .append("\", urgent: ").append(urgent)
            .append(", submitted: \"").append(submitted)
            .append("\", comments: \"").append(comments)
            .append("\", areacode: \"").append(areaCode)
            .append("\", email: \"").append(email).append("\"")
            .append("\", error: \"").append(error).append("\"")
            .append("\", errorString: \"").append(error ? errorString : "").append("\"")
            .append("}").toString();
    }
    
    

}
