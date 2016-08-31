class PermissionSwitch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.switchtype = domElement.data().switchtype;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switchtype=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class LocalSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, page) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
    this.page = page;
  }

  toggleSwitch() {
    COPO.permissions.iconToggle(this.switchtype, this.id);
    if (this.switchtype === "disallowed") {
      const bool = (this.attributeState != 'disallowed')
      this.changeDisableSwitches(bool);
    }
    if (this.switchtype === "last_only" && this.checked === true && this.attributeState === 'last_only') {
      let result = confirm("WARNING: once you turn this on, it may be possible for your entire location history to be copied before you are able to turn it off again.\
        Only share your history with highly trusted parties. Click OK to continue anyway.");
      if(!result){
        this.inputDomElement.prop("checked", !this.checked);
        return;
      }
    }
    this.permission[this.attribute] = this.nextState();
    $.ajax({
      url: `/users/${this.user}/devices/${this.permission['device_id']}/permissions/${this.id}`,
      type: 'PUT',
      dataType: 'script',
      data: { permission: this.permission, from: this.page }
    });
  }

  nextState() {
    if(this.attributeState === "disallowed") {
      return "last_only"
    } else if(this.switchtype === "disallowed") {
      return "disallowed"
    } else if(this.attributeState === "complete") {
      return "last_only"
    } else if(this.attributeState === "last_only") {
      return "complete"
    } else {
      return !this.attributeState
    }
  }
}

class MasterSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, idType, page) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
    this.page = page;
  }

  toggleSwitch() {
    if (this.switchtype === "last_only" && this.checked === true) {
      let result = confirm("WARNING: once you turn this on, it may be possible for your entire location history to be copied before you are able to turn it off again.\
        Only share your history with highly trusted parties. Click OK to continue anyway.");
      if(!result){
        this.inputDomElement.prop("checked", !this.checked);
        return;
      }
    }
    this.permissions.forEach(function(permission) {
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      const P_SWITCH = new LocalSwitch(this.user, P_DOM_ELEMENT, this.permissions, this.page);
      if ((P_SWITCH.disabled && P_SWITCH.switchtype === 'last_only')){
        this.inputDomElement.prop("checked", false)
      } else if (this.checked !== P_SWITCH.checked) {
        P_SWITCH.toggleSwitch();
        P_SWITCH.checked = this.checked;
        P_SWITCH.inputDomElement.prop("checked", this.checked);
      }
    }, this);
  }

  setState() {
    const SWITCHES_CHECKED = [];

    this.permissions.forEach(function(permission){
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      SWITCHES_CHECKED.push(P_DOM_ELEMENT.find('input').prop("checked"))
    }, this)
    const NEW_MASTER_CHECKED_STATE = _.every(SWITCHES_CHECKED)
    this.inputDomElement.prop("checked", NEW_MASTER_CHECKED_STATE)

    if (this.switchtype === "disallowed") {
      $(`div[data-id=${this.id}][data-switchtype=last_only].master`).find('input').prop("checked", false);
      const MASTERS = $(`div[data-id=${this.id}].disable.master`).find('input');
      MASTERS.prop("disabled", NEW_MASTER_CHECKED_STATE);
    }
  }
}
